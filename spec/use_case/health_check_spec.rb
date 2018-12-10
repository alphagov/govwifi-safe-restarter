describe UseCase::HealthCheck do
  subject { described_class.new(gateway: cloudwatch_gateway) }
  let(:cloudwatch_logs_gateway) { double(gt) }

  context 'it calls check_health on the gateway' do

  end
end
