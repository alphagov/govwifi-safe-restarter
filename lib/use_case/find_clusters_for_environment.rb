module UseCase
  class FindClustersForEnvironment
    def initialize(gateway:, environment:)
      @ecs_gateway = gateway
      @environment = environment
    end

    def execute
      ecs_gateway.list_clusters.select do |cluster_arn|
        # TODO: This can be updated once the migration to Fargate for
        # Frontend is completed
        cluster_arn.match?(/#{environment}-frontend/) ||
          cluster_arn.match?(/frontend-fargate/)
      end
    end

  private

    attr_reader :ecs_gateway, :environment
  end
end
