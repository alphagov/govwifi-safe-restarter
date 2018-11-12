require_relative '../../lib/use_case/safe_restart'

describe UseCase::SafeRestart do
  let(:ecs_gateway) { double }
  subject { described_class.new(ecs_gateway: ecs_gateway) }

  describe 'Safe Restart success' do
    it 'restarts returns success' do
      expect(subject.safe_restart).to eq(status: :success, errors: [])
    end
  end
end
