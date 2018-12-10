module UseCase
  class FindClustersForEnvironment
    def initialize(gateway:, environment:)
      @ecs_gateway = gateway
      @environment = environment
    end

    def execute
      ecs_gateway.list_clusters.select do |cluster_arn|
        cluster_arn.match?(/#{environment}-frontend/)
      end
    end

    private

    attr_reader :ecs_gateway, :environment
  end
end
