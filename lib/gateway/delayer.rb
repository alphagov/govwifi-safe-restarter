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

    def reset
      @retries = 0
    end

    MAX_RETRIES = 15
    DEFAULT_WAIT_TIME = 300 # 5 mins.
  end
end
