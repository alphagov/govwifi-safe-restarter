module UseCase
  class SafeRestart
    def initialize(ecs_gateway:)

    end

    def safe_restart
      { status: :success, errors: [] }
    end
  end
end
