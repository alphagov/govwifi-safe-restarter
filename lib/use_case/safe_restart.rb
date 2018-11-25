module UseCase
  class SafeRestart
    def initialize(ecs_gateway:)
      @ecs_gateway = ecs_gateway
    end

    def safe_restart
      cluster_arns = ecs_gateway.list_clusters

      cluster_arns.each do |arn|
        tasks = ecs_gateway.list_tasks(cluster: arn)
      end

      { status: :success, errors: [] }
    end

    private

    attr_reader :ecs_gateway
  end
end
