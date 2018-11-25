module UseCase
  class SafeRestart
    def initialize(ecs_gateway:, health_checker:)
      @ecs_gateway = ecs_gateway
      @health_checker = health_checker
    end

    def safe_restart
      cluster_arns = ecs_gateway.list_clusters

      cluster_arns.each do |cluster_arn|
        task_arns = ecs_gateway.list_tasks(cluster: cluster_arn)

        task_arns.each do |task_arn|
          if health_checker.healthy?(task_arn)
            ecs_gateway.stop_task(
              cluster: cluster_arn,
              task: task_arn,
              reason: 'AUTOMATED RESTART'
            )
          end
        end
      end

      { status: :success, errors: [] }
    end

    private

    attr_reader :ecs_gateway, :health_checker
  end
end
