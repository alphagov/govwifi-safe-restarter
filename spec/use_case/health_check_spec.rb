class FakeHealthyRoute53Gateway
  def get_health_check_status(health_check_id:)
    client = Aws::Route53::Client.new(stub_responses: true)

    client.stub_responses(:get_health_check_status, health_check_observations:
    [
      {
        region: "ap-southeast-2",
        ip_address: "39.239.222.111",
        status_report: {
          status: "Success: HTTP Status Code 200, OK",
        },
      },
      {
        region: "ap-eu-west-1",
        ip_address: "27.111.39.33",
        status_report: {
          status: "Success: HTTP Status Code 200, OK",
        },
      },
    ])

    client.get_health_check_status(health_check_id: health_check_id)
  end

  def list_health_checks
    client = Aws::Route53::Client.new(
      stub_responses: {
        list_health_checks: {
          max_items: 10,
          marker: "PageMarker",
          is_truncated: false,
          health_checks: [
            {
              caller_reference: "AdminMonitoring",
              id: "abc123",
              health_check_version: 1,
              health_check_config: {
                measure_latency: false,
                type: "HTTP",
              },
            },
            {
              caller_reference: "AdminMonitoring",
              id: "xyz789",
              health_check_version: 1,
              health_check_config: {
                measure_latency: false,
                type: "HTTP",
              },
            },
          ],
        },
      },
    )

    client.list_health_checks
  end
end

class FakeUnHealthyRoute53Gateway
  def get_health_check_status(health_check_id:)
    client = Aws::Route53::Client.new(stub_responses: true)

    client.stub_responses(:get_health_check_status, health_check_observations:
      [
        {
          region: "ap-southeast-2",
          ip_address: "39.239.222.111",
          status_report: {
            status: "Failure: HTTP Status Code 500, Host Unreachable",
          },
        },
      ])

    client.get_health_check_status(health_check_id: health_check_id)
  end

  def list_health_checks
    client = Aws::Route53::Client.new(
      stub_responses: {
        list_health_checks: {
          max_items: 10,
          marker: "PageMarker",
          is_truncated: false,
          health_checks: [
            {
              caller_reference: "AdminMonitoring",
              id: "latency123",
              health_check_version: 1,
              health_check_config: {
                ip_address: "123.123.123.123",
                measure_latency: false,
                type: "HTTP",
              },
            },
          ],
        },
      },
    )

    client.list_health_checks
  end
end

describe UseCase::HealthCheck do
  let(:aws_route53_gateway) { FakeHealthyRoute53Gateway.new }
  let(:delayer) { spy("Gateway::Delayer", delay: nil) }

  let(:result) do
    described_class.new(route53_gateway: aws_route53_gateway, delayer: delayer).healthy?
  end

  context "Given health checkers are healthy" do
    it "returns operational if all health checkers are healthy" do
      expect(result).to eq(true)
    end
  end

  context "Given some checkers are unhealthy" do
    let(:aws_route53_gateway) { FakeUnHealthyRoute53Gateway.new }

    it "returns an offline status" do
      expect(result).to eq(false)
    end
  end

  context "given a delayer" do
    it "delays the health checks to avoid throttling" do
      described_class.new(route53_gateway: FakeHealthyRoute53Gateway.new, delayer: delayer).healthy?
      expect(delayer).to have_received(:delay).twice.with(wait_time: 5)
    end
  end
end
