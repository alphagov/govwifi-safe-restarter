require "active_support/core_ext/module"

module Gateway
  module Aws
    class Route53
      delegate :list_health_checks, to: :client

      def initialize(config: {})
        @client = ::Aws::Route53::Client.new(aws_config(config))
      end

      def get_health_check_status(health_check_id:)
        client.get_health_check_status(health_check_id: health_check_id)
      end

    private

      DEFAULT_REGION = "eu-west-2".freeze

      attr_reader :client

      def aws_config(config)
        { region: DEFAULT_REGION }.merge(config)
      end
    end
  end
end
