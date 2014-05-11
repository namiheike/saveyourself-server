#!/usr/bin/env ruby
# $:<< '../lib' << 'lib'

require 'goliath'
# require 'goliath/plugins/latency'
require 'multi_json'
require 'net/http'
require 'uri'

class SaveYourSelfAPIService < Goliath::API
  use Goliath::Rack::Tracer             # log trace statistics
  use Goliath::Rack::DefaultMimeType    # cleanup accepted media types
  use Goliath::Rack::Render, 'json'     # auto-negotiate response format
  use Goliath::Rack::Params             # parse & merge query and body parameters
  use Goliath::Rack::Heartbeat          # respond to /status with 200, OK (monitoring, etc)

  # If you are using Golaith version <=0.9.1 you need to Goliath::Rack::ValidationError
  # to prevent the request from remaining open after an error occurs
  #use Goliath::Rack::ValidationError
  use Goliath::Rack::Validation::RequestMethod, %w(GET) # allow GET requests only
  use Goliath::Rack::Validation::RequiredParam, {key: 'x'}
  use Goliath::Rack::Validation::RequiredParam, {key: 'y'}

  # plugin Goliath::Plugin::Latency       # output reactor latency every second

  def geo_to_address(x, y)
    # uri = URI('http://api.map.baidu.com/geocoder/v2/')
    # params = {
    #   ak: '8HC4SzAudccqEF0Qj0bs8Bb4',
    #   coordtype: 'wgs84ll',
    #   location: env.params['x'] + ',' + env.params['y'],
    #   output: 'json'
    # }
    # THIS API GOT 101 ERROR

    # TODO use some non-block http api like em-synchrony/em-http

    uri = URI 'http://api.map.baidu.com/geocoder'
    params = {
      coordtype: 'wgs84ll',
      location: env.params['x'] + ',' + env.params['y'],
      output: 'json',
      src: 'OakStaffStudio|SaveYourSelf'
    }

    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      address_component = (MultiJson.load res.body)['result']['addressComponent']
      "#{address_component['city']} #{address_component['district']} #{address_component['street']}"
    end
    # TODO rescue if request failed
  end

  def get_nearest_shelter(x, y)
        
  end

  def response(env)
    [
      200,
      {
        'Content-Type' => 'application/json'
      },
      {
        address: geo_to_address(env.params['x'], env.params['y']),
        nearest_shelter: get_nearest_shelter(env.params['x'], env.params['y'])
      }
    ]
  end
end