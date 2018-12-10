module Gateway
  module Aws
    class Ecs
      def initialize(config: {})
        @client = ::Aws::ECS::Client.new(aws_config(config))
      end

      def stop_task(cluster:, task:, reason: 'AUTOMATED RESTART')
        client.stop_task(cluster: cluster, task: task, reason: reason)
      end

      def list_clusters
        client.list_clusters.cluster_arns
      end

      def list_tasks(cluster:)
        client.list_tasks(cluster: cluster).task_arns
      end

    private

      attr_reader :client

      DEFAULT_REGION = 'eu-west-2'.freeze

      def aws_config(config)
        { region: DEFAULT_REGION }.merge(config)
      end
    end
  end
end
