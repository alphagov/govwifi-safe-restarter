module Gateway
  class Delayer
    def initialize
      @retries = 0
    end

    def delay(wait_time: DEFAULT_WAIT_TIME)
      sleep(wait_time)
    end

    def increment_retries
      @retries += 1
      p "current retries: #{@retries}"
    end

    def max_retries_reached?
      @retries >= MAX_RETRIES
    end

    MAX_RETRIES = 10
    DEFAULT_WAIT_TIME = 600 # Cloudwatch health checks are 2 mins, 600 seconds is 10 mins
  end
end
