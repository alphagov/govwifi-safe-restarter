require 'sinatra/base'

class App < Sinatra::Base
  configure :production, :staging, :development do
    enable :logging
  end

  get '/safe-restart' do
  end
end
