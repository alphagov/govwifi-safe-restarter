describe UseCase::HealthCheck do
  subject do
    described_class.new(
      cloudwatch_logs_gateway: cloudwatch_logs_gateway
    )
  end

  let(:cloudwatch_logs_gateway) { double(healthy?: nil) }

  context 'Given the Cloudwatch Logs Gateway' do
    it 'calls healthy? on it' do
      subject.execute(log_group_name: 'SomeLogGroupName')
      expect(cloudwatch_logs_gateway).to have_received(:healthy?)
        .with(
          log_group_name: 'SomeLogGroupName',
          filter_pattern: 'Access-Accept'
        )
    end
  end
end
