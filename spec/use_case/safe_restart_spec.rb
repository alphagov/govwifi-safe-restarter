require_relative "../../lib/use_case/safe_restart"

class DelayerFake
  attr_accessor :health_check_retry_limit

  def initialize
    @retries = 0
  end

  def delay; end

  def increment_retries
    @retries += 1
  end

  def max_retries_reached?
    @retries > health_check_retry_limit
  end
end

class EventuallyHealthyHealthCheckFake
  def initialize
    @call_count = 0
  end

  def healthy?
    @call_count += 1
    @call_count == 1 || @call_count > 4
  end
end

class HealthyUntilFirstRestartFake
  def initialize
    @call_count = 0
  end

  def healthy?
    @call_count += 1
    @call_count == 1
  end
end

class NeverHealthyFake
  def initialize; end

  def healthy?
    false
  end
end

describe UseCase::SafeRestart do
  let(:health_checker) { EventuallyHealthyHealthCheckFake.new }
  let(:delayer) { DelayerFake.new }
  let(:some_cluster_arn) { "arn:aws:ecs:eu-west-2:123:cluster/some-cluster" }
  let(:cluster_finder) { double(execute: [some_cluster_arn]) }
  let(:ecs_gateway) { double(list_tasks: [], stop_task: nil) }
  let(:restart_reason) { "AUTOMATED RESTART" }
  let(:logger) { double(info: nil) }

  subject do
    described_class.new(
      cluster_finder:,
      ecs_gateway:,
      health_checker:,
      delayer:,
      logger:,
    )
  end

  describe "Safe Restart abort" do
    let(:health_checker) { NeverHealthyFake.new }

    it "does not try restart the services if the health checks are unhealthy" do
      expect { subject.execute }.to raise_error(
        "Cannot Reboot Cluster, Health Checks failed",
      )
      expect(ecs_gateway).to_not have_received(:stop_task)
    end
  end

  describe "Safe Restart success" do
    before do
      delayer.health_check_retry_limit = 5
    end

    context "Clusters" do
      it "calls execute on the environment cluster finder" do
        subject.execute
        expect(cluster_finder).to have_received(:execute)
      end

      context "Tasks" do
        let(:some_task_arn1) { "arn:aws:ecs:eu-west-2:123:task/fe2c820a-98d9" }
        let(:some_task_arn2) { "arn:aws:ecs:eu-west-2:123:task/abcs903s-930a" }
        let(:some_task_arn3) { "arn:aws:ecs:eu-west-2:123:task/abcs390s-abcd" }

        let(:ecs_gateway) do
          double(list_tasks: [some_task_arn1, some_task_arn2, some_task_arn3], stop_task: true)
        end

        it "calls list_tasks on the ECS gateway" do
          subject.execute
          expect(ecs_gateway).to have_received(:list_tasks).with(cluster: some_cluster_arn).at_least(:once)
        end

        context "Health Check" do
          context "Healthy" do
            before do
              allow(ecs_gateway).to receive(:stop_task)
              subject.execute
            end

            it "stops the first task - canary" do
              expect(ecs_gateway).to have_received(:stop_task).with(
                cluster: some_cluster_arn,
                task: some_task_arn1,
                reason: restart_reason,
              )
            end

            it "stops the second task" do
              expect(ecs_gateway).to have_received(:stop_task).with(
                cluster: some_cluster_arn,
                task: some_task_arn2,
                reason: restart_reason,
              ).exactly(:once)
            end

            it "stops the third of the tasks" do
              expect(ecs_gateway).to have_received(:stop_task).with(
                cluster: some_cluster_arn,
                task: some_task_arn3,
                reason: restart_reason,
              ).exactly(:once)
            end
          end

          context "Not Healthy" do
            let(:health_checker) { HealthyUntilFirstRestartFake.new }
            let(:error_message) { "MAX RETRIES REACHED" }

            before do
              delayer.health_check_retry_limit = 1
            end

            it "raises an error" do
              expect { subject.execute }.to raise_error(error_message)
            end

            it "calls stop task on the canary" do
              expect { subject.execute }.to raise_error(error_message)
              expect(ecs_gateway).to have_received(:stop_task).with(
                cluster: some_cluster_arn,
                task: some_task_arn1,
                reason: restart_reason,
              )
            end

            it "does not call stop on the rest of the tasks for the cluster" do
              expect { subject.execute }.to raise_error(error_message)
              expect(ecs_gateway).to_not have_received(:stop_task).with(
                cluster: some_cluster_arn,
                task: some_task_arn2,
                reason: restart_reason,
              )
            end
          end
        end
      end
    end
  end
end
