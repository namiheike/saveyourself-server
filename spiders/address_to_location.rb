require 'moped'

session = Moped::Session.new([ 'localhost:27017' ])
session.use 'saveyourself_development'

# session.with(safe: true) do |safe|
#   safe[:artists].insert(name: "Syd Vicious")
# end

# session[:artists].find(name: "Syd Vicious").update(:$push => { instruments: { name: "Bass" }})

# def get_geolocation(address)
  
# end