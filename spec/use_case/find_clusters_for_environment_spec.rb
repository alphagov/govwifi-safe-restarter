describe UseCase::FindClustersForEnvironment do
  subject { described_class.new(gateway: ecs_gateway, environment:) }

  let(:ecs_gateway) do
    double(list_clusters: [
      "arn:aws:ecs:eu-west-2:abc123:cluster/frontend-fargate",
      "arn:aws:ecs:eu-west-2:abc123:cluster/other-cluster",
    ])
  end

  context "given Staging" do
    let(:environment) { "staging" }

    it "finds only staging clusters" do
      expect(subject.execute).to eq(["arn:aws:ecs:eu-west-2:abc123:cluster/frontend-fargate"])
    end
  end

  context "given Production" do
    let(:environment) { "wifi" }

    it "finds only production clusters" do
      expect(subject.execute).to eq(["arn:aws:ecs:eu-west-2:abc123:cluster/frontend-fargate"])
    end
  end
end
