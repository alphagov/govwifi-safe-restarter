module UseCase
  class SafeRestart
    def initialize(cluster_finder:, ecs_gateway:, health_checker:, delayer:, notifier:)
      @ecs_gateway = ecs_gateway
      @health_checker = health_checker
      @delayer = delayer
      @notifier = notifier
      @cluster_finder = cluster_finder
    end

    def safe_restart
      cluster_arns.each { |cluster| rolling_restart_cluster(cluster) }
    end

    private

    def rolling_restart_cluster(cluster_arn)
      tasks = task_arns(cluster_arn)
      canary, *rest = *tasks
      stop_tasks(tasks, [canary], cluster_arn)

      live_canary = newest_task(cluster_arn, tasks)

      until health_checker.healthy?(live_canary)
        return if :timed_out == wait_for_task_with_timeout(tasks, cluster_arn)
      end

      stop_tasks(tasks, rest, cluster_arn)
    end

    def stop_tasks(all_tasks, tasks, cluster_arn)
      tasks.each do |task_arn|
        stop_task(cluster_arn, task_arn)

        until all_tasks.count == task_arns(cluster_arn).count
          return if :timed_out == wait_for_task_with_timeout(all_tasks, cluster_arn)
        end
      end

    end

    def cluster_arns
      cluster_finder.execute
    end

    def task_arns(cluster)
      ecs_gateway.list_tasks(cluster: cluster)
    end

    def stop_task(cluster, task)
      ecs_gateway.stop_task(
        cluster: cluster,
        task: task,
        reason: 'AUTOMATED RESTART'
      )
    end

    def newest_task(cluster, tasks)
      task_arns(cluster) - tasks
    end

    def wait_for_task_with_timeout(tasks, cluster_arn)
      delayer.delay
      delayer.increment_retries

      if delayer.max_retries_reached?
        notifier.notify
        return :timed_out
      end
    end

    attr_reader :ecs_gateway, :health_checker, :delayer, :notifier, :cluster_finder
  end
end
