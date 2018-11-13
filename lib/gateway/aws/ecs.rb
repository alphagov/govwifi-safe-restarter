module Gateway
  module Aws
    class Ecs
      def initialize(aws_config: {})
        @aws_config = aws_config
        @client = ::Aws::ECS::Client.new(config)
      end

      def list_clusters
        client.list_clusters.cluster_arns
      end

      def list_tasks(cluster:)
        client.list_tasks(cluster: cluster).task_arns
      end

      private

      attr_reader :aws_config, :client

      DEFAULT_REGION = 'eu-west-2'.freeze

      def config
        { region: DEFAULT_REGION }.merge(aws_config)
      end
    end
  end
end
