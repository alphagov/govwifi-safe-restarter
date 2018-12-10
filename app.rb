require 'sinatra/base'
require './lib/loader'

class App < Sinatra::Base
  configure :production, :staging, :development do
    enable :logging
  end
end
