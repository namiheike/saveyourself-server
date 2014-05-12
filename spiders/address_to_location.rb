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
    type: 'Point',
    coordinates: [location['lng'], location['lat']]
  }
end

cities = ['shanghai']
cities.each do |city|
  puts '###'
  puts city

  # load from file
  content = MultiJson.load File.read("cities/#{city}.json")

  content.each_index do |i|
    puts content[i]['city_name'] + content[i]['name']
    address = content[i]['city_name'] + content[i]['address']
    puts address
    content[i]['location'] = address_to_location address
    puts content[i]['location']
  end

  # write to file
  File.open("cities/#{city}.json", 'w') { |file| file.write( MultiJson.dump content, pretty: true ) }
end

