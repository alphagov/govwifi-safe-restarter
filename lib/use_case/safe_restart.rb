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
      # unless health_checker.healthy?
      #   raise "Cannot Reboot Cluster, Health Checks failed"
      # end

      cluster_finder.execute.each do |cluster|
        rolling_restart_cluster(cluster)

        delayer.reset
      end
    end

  private

    def rolling_restart_cluster(cluster)
      p "Rolling restart is starting on #{cluster}"
      tasks = cluster_tasks(cluster)
      p "Tasks for #{cluster} are #{tasks}"
      canary, *rest = *tasks
      p "Canary is: #{canary}"
      p "Rest is: #{rest}"
      restart_and_wait_for(canary, tasks, cluster)
      # wait_or_timeout until health_checker.healthy?

      p "Moving onto the rest"
      rest.each do |task|
        p "Rest task #{task} is about to be restarted"
        restart_and_wait_for(task, tasks, cluster)
      end
    end

    def restart_and_wait_for(task, original_tasks, cluster)
      stop_task(cluster, task)

      # Give the new task a chance to start before checking the count
      delayer.delay

      wait_or_timeout until original_tasks.count == cluster_tasks(cluster).count
    end

    def cluster_tasks(cluster)
      ecs_gateway.list_tasks(cluster:)
    end

    def stop_task(cluster, task)
      p "Stopping task #{task} in cluster #{cluster}"
      ecs_gateway.stop_task(cluster:, task:, reason: "AUTOMATED RESTART")
    end

    def wait_or_timeout
      delayer.delay
      p "incrementing retries"
      delayer.increment_retries

      if delayer.max_retries_reached?
        raise "MAX RETRIES REACHED"
      end
    end

    attr_reader :ecs_gateway, :health_checker, :delayer, :cluster_finder, :logger
  end
end
