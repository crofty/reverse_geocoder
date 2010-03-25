
RACK_ENV = 'development'

require 'rubygems'
require 'sinatra/base'
require "sequel"
require 'yajl'
require 'yajl/json_gem'
require 'yaml'

# Setup DB
content = File.new("config/database.yml").read
settings = YAML::load(content)[RACK_ENV]
DB = Sequel.connect "#{settings['adapter']}://#{settings['username']}:#{settings['password']}@#{settings['host']}/#{settings['database']}"

Dir.glob(File.join(File.dirname(__FILE__), 'lib/*.rb')).each {|f| require f }

class ReverseGeocoder < Sinatra::Base

  get '/' do
    JSON.generate Location.new(params[:lng],params[:lng]).address
  end

end

ReverseGeocoder.run! :host => 'localhost', :port => 9090

