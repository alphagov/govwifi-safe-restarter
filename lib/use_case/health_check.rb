module UseCase
  class HealthCheck
    def initialize(cloudwatch_logs_gateway:)
      @cloudwatch_logs_gateway = cloudwatch_logs_gateway
    end

    def execute(log_group_name:)
      cloudwatch_logs_gateway.healthy?(
        log_group_name: log_group_name,
        filter_pattern: HEALTHY_MATCH_PATTERN
      )
    end

    private

    HEALTHY_MATCH_PATTERN = 'Access-Accept'.freeze

    attr_reader :cloudwatch_logs_gateway
  end
end
