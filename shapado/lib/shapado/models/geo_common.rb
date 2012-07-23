module Shapado
module Models
  module GeoCommon
    extend ActiveSupport::Concern

    included do
      field :address, :type => Hash, :default => {}
      field :position, :type => Hash, :default => {"lat" => 0.0, "long" => 0.0}
      index [[:position, Mongo::GEO2D]]

      before_save :float_position

      def float_position
        position["lat"] = Float(position["lat"]||0)
        position["long"] = Float(position["long"]||0)
      end
    end

    #InstanceMethods

    def set_address(ip)
      lat = self["position"]["lat"]
      long = self["position"]["long"]
      if defined?(Localize) && (lat == 0.0 || long == 0.0)
       geoip = Rails.cache.fetch("geoip_#{ip}") do
          Localize.city(ip)
        end
        if geoip
          lat = geoip.latitude
          long = geoip.longitude
        end
      end

      if lat != 0.0 || long != 0.0
        self["address"] = Nominatim::Place.new(lat, long).get_address
        self["position"] = { "lat" => lat, "long" => long}
        self.save
        if self.user.address != self.address
          self.user.position = self.position
          self.user.address = self.address
          self.user.save
        end
      end
    end

    def address_name
      address = if self.address.present? && self.address != { }
                  unless self.address["city"].blank?
                    "#{self.address["city"]}, #{self.address["country"]}"
                  else
                    self.address["country"] || I18n.t('global.unknown_place')
                  end
                else
                  I18n.t('global.unknown_place')
                end
    end

    def point(max_distance=6)
      @_point ||= self.position.merge({:$maxDistance=>6})
    end
  end
end
end
