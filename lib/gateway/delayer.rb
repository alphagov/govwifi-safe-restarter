module Gateway
  class Delayer
    def initialize
      @retries = 0
    end

    def delay
      logger.info "delaying for #{WAIT_TIME} seconds"
      sleep(WAIT_TIME)
    end

    def increment_retries
      @retries += 1
      logger.info "retries increased to #{@retries}"
    end

    def max_retries_reached?
      logger.info "checking if max retries reached #{@max_retries_reached}"
      @retries >= MAX_RETRIES
    end

    MAX_RETRIES = 4
    WAIT_TIME = 200 # Cloudwatch health checks are 2 mins, 150 seconds is just over 2 mins
  end
end
