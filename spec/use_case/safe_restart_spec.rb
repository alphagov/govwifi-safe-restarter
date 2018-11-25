require_relative '../../lib/use_case/safe_restart'

describe UseCase::SafeRestart do
  let(:ecs_gateway) { double(list_clusters: []) }
  let(:health_checker) { double(healthy?: false) }

  subject do
    described_class.new(
      ecs_gateway: ecs_gateway,
      health_checker: health_checker
    )
  end

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
        let(:some_task_arn) { 'arn:aws:ecs:eu-west-2:123:task/fe2c820a-98d9' }
        let(:ecs_gateway) do
          double(
            list_clusters: [some_cluster_arn],
            list_tasks: [some_task_arn],
            stop_task: true,
          )
        end

        before do
          subject.safe_restart
        end

        it 'calls list_tasks on the ECS gateway' do
          expect(ecs_gateway).to have_received(:list_tasks).with(cluster: some_cluster_arn)
        end

        context 'Health Check' do
          context 'Healthy' do
            let(:health_checker) { double(healthy?: true) }

            before do
              allow(ecs_gateway).to receive(:stop_task)
            end

            it 'calls list_tasks on the ECS gateway' do
              expect(ecs_gateway).to have_received(:stop_task).with(
                cluster: some_cluster_arn,
                task: some_task_arn,
                reason: 'AUTOMATED RESTART'
              )
            end
          end
        end
      end
    end
  end
end
