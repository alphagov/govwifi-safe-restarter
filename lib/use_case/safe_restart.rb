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
        p "Rolling Restart #{cluster}"
        rolling_restart_cluster(cluster)
      end
    end

  private

    def rolling_restart_cluster(cluster_arn)
      tasks = task_arns(cluster_arn)
      canary, *rest = *tasks
      p "tasks: #{tasks}"
      p "stopping canary #{canary}"
      stop_and_wait_for_tasks(tasks, [canary], cluster_arn)

      p "CANARY HEALTH CHECK: #{health_checker.healthy?}"

      wait until health_checker.healthy?

      if health_checker.healthy?
        stop_and_wait_for_tasks(tasks, rest, cluster_arn)
      end
    end

    def stop_and_wait_for_tasks(all_tasks, tasks, cluster_arn)
      tasks.each do |task_arn|
        p "stopping #{task_arn}"
        stop_task(cluster_arn, task_arn)

        wait until all_tasks.count == task_arns(cluster_arn).count
      end
    end

    def task_arns(cluster)
      ecs_gateway.list_tasks(cluster: cluster)
    end

    def stop_task(cluster, task)
      ecs_gateway.stop_task(cluster: cluster, task: task, reason: 'AUTOMATED RESTART')
    end

    def wait
      delayer.delay
      delayer.increment_retries

      if delayer.max_retries_reached?
        raise 'MAX RETRIES REACHED'
      end
    end

    attr_reader :ecs_gateway, :health_checker, :delayer, :cluster_finder
  end
end
