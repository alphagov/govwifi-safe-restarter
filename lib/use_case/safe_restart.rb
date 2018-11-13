module UseCase
  class SafeRestart
    def initialize(ecs_gateway:)
      @ecs_gateway = ecs_gateway
    end

    def safe_restart
      ecs_gateway.list_clusters

      { status: :success, errors: [] }
    end

    private

    attr_reader :ecs_gateway
  end
end
