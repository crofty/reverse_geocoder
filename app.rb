require 'rubygems'
require 'sinatra/base'
require "sequel"
require 'yajl'
require 'yajl/json_gem'
require 'yaml'

ENV['RACK_ENV'] ||= 'development'

# Setup DB
content = File.new("config/database.yml").read
settings = YAML::load(content)[ENV['RACK_ENV']]
DB = Sequel.connect "#{settings['adapter']}://#{settings['username']}:#{settings['password']}@#{settings['host']}/#{settings['database']}"

Dir.glob(File.join(File.dirname(__FILE__), 'lib/*.rb')).each {|f| require f }

class ReverseGeocoder < Sinatra::Base

  get '/' do
    content_type :json
    JSON.generate Location.new(params[:lat].to_f,params[:lng].to_f).address if params[:lat] && params[:lng]
  end

end


