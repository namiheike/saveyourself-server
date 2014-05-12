#!/usr/bin/env ruby

# 1. make the phone attribute string instead of integer

# 2. make phone attr 'xxx' into ['xxx']

# 3. some local station got multi phones
# for that, change string 'xxx yyy' to an array like ['xxx', 'yyy']

# 4. some local station's phone is a redirect type, like: 11111111-222
# for that, make 11111111 the phone attribute, and 1111111-222 the `phone_in_fact` attribute


require 'multi_json'

cities = ['shanghai']
cities.each do |city|
  puts '###'
  puts city

  # load from file
  content = MultiJson.load File.read("cities/#{city}.json")

  content.each_index do |i|
    shelter = content[i]

    shelter['phone'] = shelter['phone'].to_s if not shelter['phone'].is_a? Array

    if shelter['phone'].include? ' '
      shelter['phone'] = shelter['phone'].split ' '
    else
      if not shelter['phone'].is_a? Array
        shelter['phone'] = [shelter['phone']]
      end
    end

    shelter['phone'].each_index do |j|
      if shelter['phone'][j].include? '-'
        phone_in_fact = shelter['phone'][j]
        shelter['phone'][j] = shelter['phone'][j].split('-').first
        if shelter['phone_in_fact'] then
          shelter['phone_in_fact'] << phone_in_fact
        else
          shelter['phone_in_fact'] = [phone_in_fact]
        end
      end
    end

    content['shelters'][i] = shelter
  end

  # write to file
  File.open("cities/#{city}.json", 'w') { |file| file.write( MultiJson.dump content, pretty: true ) }
end
