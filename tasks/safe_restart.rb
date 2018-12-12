require 'logger'

require 'require_all'
require_all 'lib'
logger = Logger.new(STDOUT)

task :safe_restart, :environment do |_, args|
  unless %w(staging production).include?(args['environment'])
    abort 'An environment of "staging" or "production" must be specified'
  end

  environment = args.fetch(:environment)
  environment = environment == 'production' ? 'wifi' : environment # very unfortunate

  %w(eu-west-1 eu-west-2).each do |region|
    p "== SAFE RESTARTING #{region} =="
    ecs_gateway = Gateway::Aws::Ecs.new(config: { region: region })
    route53_gateway = Gateway::Aws::Route53.new
    cluster_finder = UseCase::FindClustersForEnvironment.new(gateway: ecs_gateway, environment: environment)
    health_checker = UseCase::HealthCheck.new(route53_gateway: route53_gateway)
    delayer = Gateway::Delayer.new

    UseCase::SafeRestart.new(
      cluster_finder: cluster_finder,
      ecs_gateway: ecs_gateway,
      health_checker: health_checker,
      delayer: delayer,
      logger: logger
    ).execute

    cluster_finder.execute
  end

  p 'SAFE RESTARTING COMPLETED'
end
