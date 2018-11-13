require_relative '../../lib/use_case/safe_restart'

describe UseCase::SafeRestart do
  let(:ecs_gateway) { double(list_clusters: nil) }
  subject { described_class.new(ecs_gateway: ecs_gateway) }

  describe 'Safe Restart success' do
    it 'returns success' do
      expect(subject.safe_restart).to eq(status: :success, errors: [])
    end

    it 'calls list_clusters on the ECS gateway' do
      subject.safe_restart
      expect(ecs_gateway).to have_received(:list_clusters)
    end
  end
end
