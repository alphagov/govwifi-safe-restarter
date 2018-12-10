require 'sinatra/base'
require './lib/loader'

class App < Sinatra::Base
  enable :logging
end
