module UseCase
  class SafeRestart
    def initialize(cluster_finder:, ecs_gateway:, health_checker:, delayer:, logger:)
      @ecs_gateway = ecs_gateway
      @health_checker = health_checker
      @delayer = delayer
      @cluster_finder = cluster_finder
      @logger = logger
    end

    def execute
      cluster_finder.execute.each do |cluster|
        rolling_restart_cluster(cluster)
      end
    end

  private

    def rolling_restart_cluster(cluster_arn)
      tasks = task_arns(cluster_arn)
      canary, *rest = *tasks
      restart_and_wait_for(canary, tasks, cluster_arn)
      wait_or_timeout until health_checker.healthy?

      rest.each { |task| restart_and_wait_for(task, tasks, cluster_arn) }
    end

    def restart_and_wait_for(task_arn, original_tasks, cluster_arn)
      stop_task(cluster_arn, task_arn)
      wait_or_timeout until original_tasks.count == task_arns(cluster_arn).count
    end

    def task_arns(cluster)
      ecs_gateway.list_tasks(cluster: cluster)
    end

    def stop_task(cluster, task)
      ecs_gateway.stop_task(cluster: cluster, task: task, reason: 'AUTOMATED RESTART')
    end

    def wait_or_timeout
      delayer.delay
      delayer.increment_retries

      if delayer.max_retries_reached?
        raise 'MAX RETRIES REACHED'
      end
    end

    attr_reader :ecs_gateway, :health_checker, :delayer, :cluster_finder, :logger
  end
end
