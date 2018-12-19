module Gateway
  class Delayer
    def initialize
      @retries = 0
    end

    def delay
      sleep(WAIT_TIME)
    end

    def increment_retries
      @retries += 1
      p "current retries: #{@retries}"
    end

    def max_retries_reached?
      @retries >= MAX_RETRIES
    end

    MAX_RETRIES = 10
    WAIT_TIME = 150 # Cloudwatch health checks are 2 mins, 150 seconds is just over 2 mins
  end
end
