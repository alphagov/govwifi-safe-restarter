require_relative '../../lib/use_case/safe_restart'

describe UseCase::SafeRestart do
  let(:ecs_gateway) { double(list_clusters: []) }
  subject { described_class.new(ecs_gateway: ecs_gateway) }

  describe 'Safe Restart success' do
    it 'returns success' do
      expect(subject.safe_restart).to eq(status: :success, errors: [])
    end

    context 'Clusters' do
      it 'calls list_clusters on the ECS gateway' do
        subject.safe_restart
        expect(ecs_gateway).to have_received(:list_clusters)
      end

      context 'Tasks' do
        let(:some_cluster_arn) { 'arn:aws:ecs:eu-west-2:123:cluster/some-cluster' }
        let(:ecs_gateway) { double(list_clusters: [some_cluster_arn]) }

        before do
          allow(ecs_gateway).to receive(:list_tasks)
        end

        it 'calls list_tasks on the ECS gateway' do
          subject.safe_restart
          expect(ecs_gateway).to have_received(:list_tasks).with(cluster: some_cluster_arn)
        end

        context 'Health Check' do

        end
      end
    end
  end
end
