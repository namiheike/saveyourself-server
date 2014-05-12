#!/usr/bin/env ruby

# read json file, get loc from address, export json to file

require 'multi_json'
require 'uri'
require 'net/http'

require 'awesome_print'
# require 'pry'

def address_to_location(address)
  # TODO change to web API (the one with secret key)
  uri = URI 'http://api.map.baidu.com/geocoder'
  params = {
    address: address,
    output: 'json',
    coord_type: 'wgs84',
    src: 'OakStaffStudio|SaveYourSelf'
  }
  uri.query = URI.encode_www_form(params)

  # puts res.body if res.is_a?(Net::HTTPSuccess)
  # TODO rescue if request failed
  location = (MultiJson.load Net::HTTP.get_response(uri).body)['result']['location']
  {
    longitude: location['lng'],
    latitude: location['lat']
  }
end

cities = ['shanghai']
cities.each do |city|
  puts '###'
  puts city

  # load from file
  content = MultiJson.load File.read("cities/#{city}.json")
  city_name = content['name']

  content['shelters'].each_index do |i|
    puts content['shelters'][i]['name']
    address = city_name + content['shelters'][i]['address']
    puts address
    content['shelters'][i]['location'] = address_to_location address
    puts content['shelters'][i]['location']
  end

  # write to file
  File.open("cities/#{city}.json", 'w') { |file| file.write( MultiJson.dump content, pretty: true ) }
end

