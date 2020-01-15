describe UseCase::FindClustersForEnvironment do
  subject { described_class.new(gateway: ecs_gateway, environment: environment) }

  let(:ecs_gateway) do
    double(list_clusters: [
      "arn:aws:ecs:eu-west-2:abc123:cluster/staging-frontend-cluster",
      "arn:aws:ecs:eu-west-2:abc123:cluster/wifi-frontend-cluster",
      "arn:aws:ecs:eu-west-2:abc123:cluster/staging-some-other-cluster",
      "arn:aws:ecs:eu-west-2:abc123:cluster/wifi-some-other-cluster",
    ])
  end

  context "given Staging" do
    let(:environment) { "staging" }

    it "finds only staging clusters" do
      expect(subject.execute).to eq(["arn:aws:ecs:eu-west-2:abc123:cluster/staging-frontend-cluster"])
    end
  end

  context "given Production" do
    let(:environment) { "wifi" }

    it "finds only production clusters" do
      expect(subject.execute).to eq(["arn:aws:ecs:eu-west-2:abc123:cluster/wifi-frontend-cluster"])
    end
  end
end
