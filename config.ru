require 'app'

app = Rack::Builder.app do
  run ReverseGeocoder
end

run app
