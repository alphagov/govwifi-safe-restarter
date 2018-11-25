require_relative '../../../lib/gateway/aws/ecs'

describe Gateway::Aws::Ecs do
  subject { described_class.new(aws_config: config) }

  context 'clusters' do
    let(:config) do
      {
        stub_responses:
        {
          list_clusters: double(cluster_arns: ['arn:aws:ecs:eu-west-2:123457:cluster/some-frontend-cluster'])
        }
      }
    end

    it 'returns a list of clusters' do
      expect(subject.list_clusters).to eq(['arn:aws:ecs:eu-west-2:123457:cluster/some-frontend-cluster'])
    end
  end

  context 'tasks' do
    let(:config) do
      {
        stub_responses:
        {
          list_tasks: double(task_arns: ['arn:aws:ecs:eu-west-2:1234:task/xxxylyy3-bead-4d17-b6c2-f9bb0fc97c67'])
        }
      }
    end

    it 'returns tasks belonging to the clusters' do
      expect(subject.list_tasks(cluster: 'some-cluster')).to eq(
        ['arn:aws:ecs:eu-west-2:1234:task/xxxylyy3-bead-4d17-b6c2-f9bb0fc97c67']
      )
    end
  end
end
