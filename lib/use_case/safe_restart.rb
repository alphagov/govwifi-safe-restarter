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
      unless health_checker.healthy?
        raise 'Cannot Reboot Cluster, Health Checks failed'
      end

      cluster_finder.execute.each do |cluster|
        rolling_restart_cluster(cluster)
      end
    end

  private

    def rolling_restart_cluster(cluster)
      tasks = tasks(cluster)
      canary, *rest = *tasks
      p "Stopping Canary: #{canary}"
      restart_and_wait_for(canary, tasks, cluster)
      wait_or_timeout until health_checker.healthy?

      p "Stopping the Rest: #{rest}"
      rest.each { |task| restart_and_wait_for(task, tasks, cluster) }
    end

    def restart_and_wait_for(task, original_tasks, cluster)
      stop_task(cluster, task)
      wait_or_timeout until original_tasks.count == tasks(cluster).count
      p "New Task has come back up: #{task}"
    end

    def tasks(cluster)
      ecs_gateway.list_tasks(cluster: cluster)
    end

    def stop_task(cluster, task)
      ecs_gateway.stop_task(cluster: cluster, task: task, reason: 'AUTOMATED RESTART')
    end

    def wait_or_timeout
      p 'sleeping'
      delayer.delay
      p 'incrementing retries'
      delayer.increment_retries

      if delayer.max_retries_reached?
        raise 'MAX RETRIES REACHED'
      end
    end

    attr_reader :ecs_gateway, :health_checker, :delayer, :cluster_finder, :logger
  end
end
