#!/usr/bin/env ruby
# $:<< '../lib' << 'lib'

require 'goliath'
# require 'goliath/plugins/latency'
require 'multi_json'
require 'em-synchrony/em-http'

# class API < Grape:: API
   # https://gist.github.com/lgs/3048953
# end

class Server < Goliath::API
  use Goliath::Rack::Tracer             # log trace statistics
  use Goliath::Rack::DefaultMimeType    # cleanup accepted media types
  # use Goliath::Rack::Render, 'json'     # auto-negotiate response format
  use Goliath::Rack::Params             # parse & merge query and body parameters
  # use Goliath::Rack::JSONP
  # TODO use goliath's JSONP rack
  use Goliath::Rack::Heartbeat          # respond to /status with 200, OK (monitoring, etc)

  # If you are using Golaith version <=0.9.1 you need to Goliath::Rack::ValidationError
  # to prevent the request from remaining open after an error occurs
  #use Goliath::Rack::ValidationError
  use Goliath::Rack::Validation::RequestMethod, %w(GET) # allow GET requests only
  use Goliath::Rack::Validation::RequiredParam, {key: 'longitude'}
  use Goliath::Rack::Validation::RequiredParam, {key: 'latitude'}

  # plugin Goliath::Plugin::Latency       # output reactor latency every second

  def geo_to_address(longitude, latitude)
    # uri = URI('http://api.map.baidu.com/geocoder/v2/')
    # params = {
    #   ak: '8HC4SzAudccqEF0Qj0bs8Bb4',
    #   coordtype: 'wgs84ll',
    #   location: env.params['x'] + ',' + env.params['y'],
    #   output: 'json'
    # }
    # THIS API GOT 101 ERROR

    api_url = 'http://api.map.baidu.com/geocoder'
    api_params = {
      coordtype: 'wgs84ll',
      location: latitude + ',' + longitude, # WARNING: fuxxing baidu use (lat, lon) instead of (lon, lat)
      output: 'json',
      src: 'OakStaffStudio|SaveYourSelf'
    }
    (MultiJson.load (EM::HttpRequest.new(api_url).get :query => api_params).response)['result']['addressComponent']
  end

  def get_nearest_shelters(city, longitude, latitude)
    moped[:shelters].find({
      city_name: city,
      location: {
        "$near" => {
          "$geometry" => {
            type: "Point",
            coordinates: [1,1]
          }
        }
      }
    }).select(_id: 0, name: 1, phone: 1, address: 1).limit(3).to_a
  end

  def response(env)
    address_component = geo_to_address(env.params['longitude'], env.params['latitude'])
    response = {
        address: "#{address_component['city']} #{address_component['district']} #{address_component['street']}",
        nearest_shelters: get_nearest_shelters(address_component['city'], env.params['longitude'], env.params['latitude'])
    }
    response_str = "#{env.params['callback']}(#{MultiJson.dump response})"
    [
      200,
      {
        'Content-Type' => 'application/javascript'
      },
      response_str
    ]
  end
end
