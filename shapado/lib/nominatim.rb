require 'open-uri'
require 'json'

module Nominatim
  class Place
    attr_reader :lat, :long
    def initialize(lat, long)
      @lat = lat
      @long = long
    end

    def get_address
      url = "http://open.mapquestapi.com/nominatim/v1/reverse?format=json&lat=#{self.lat}&lon=#{self.long}"
      begin
        data = Rails.cache.fetch("osm_lat#{self.lat}lon#{self.long}") do
          JSON.parse(open(url).read)["address"]
        end
      rescue
        { }
      end
    end

    def get_address_from_country(country)
      country = country.split(',').first
      url = URI.escape("http://nominatim.openstreetmap.org/search?q=#{country}&format=json&polygon=1&addressdetails=1&limit=1")
      data = JSON.parse(open(url).read)
    end
  end
end
