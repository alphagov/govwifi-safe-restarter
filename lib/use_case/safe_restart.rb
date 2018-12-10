module UseCase
  class SafeRestart
    def initialize(cluster_finder:, ecs_gateway:, health_checker:, delayer:)
      @ecs_gateway = ecs_gateway
      @health_checker = health_checker
      @delayer = delayer
      @cluster_finder = cluster_finder
    end

    def execute
      cluster_finder.execute.each do |cluster|
        "Rolling Restart #{cluster}"
        rolling_restart_cluster(cluster)
      end
    end

    private

    def rolling_restart_cluster(cluster_arn)
      tasks = task_arns(cluster_arn)
      canary, *rest = *tasks
      p "tasks: #{tasks}"
      p "stopping canary #{canary}"
      stop_tasks(tasks, [canary], cluster_arn)
      live_canary = newest_task(cluster_arn, tasks)

      p "live canary is: #{live_canary}"

      p "CANARY HEALTH CHECK: #{health_checker.healthy?}"

      until health_checker.healthy?
        p "HEALTH CHECK TIMED OUT"
        return if :timed_out == wait_for_task_with_timeout(tasks, cluster_arn)
      end

      p "Successfully restarted the canary, moving onto the rest"

      p "REST HEALTH CHECK: #{health_checker.healthy?}"
      if health_checker.healthy?
        stop_tasks(tasks, rest, cluster_arn)
      end
    end

    def stop_tasks(all_tasks, tasks, cluster_arn)
      tasks.each do |task_arn|
        stop_task(cluster_arn, task_arn)

        until all_tasks.count == task_arns(cluster_arn).count
          p 'stopping'
          return if :timed_out == wait_for_task_with_timeout(all_tasks, cluster_arn)
        end
      end
    end

    def task_arns(cluster)
      ecs_gateway.list_tasks(cluster: cluster)
    end

    def stop_task(cluster, task)
      ecs_gateway.stop_task(cluster: cluster, task: task, reason: 'AUTOMATED RESTART')
    end

    def newest_task(cluster, tasks)
      task_arns(cluster) - tasks
    end

    def wait_for_task_with_timeout(tasks, cluster_arn)
      delayer.delay
      delayer.increment_retries

      if delayer.max_retries_reached?
        :timed_out
      end
    end

    attr_reader :ecs_gateway, :health_checker, :delayer, :cluster_finder
  end
end
