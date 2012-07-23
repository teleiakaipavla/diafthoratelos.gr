class GeoPosition
  include Mongoid::Fields::Serializable

  attr_reader :lat, :long

  def serialize(value)
    return if value.nil?

    if value.is_a?(self.class)
      {'lat' => value.lat.to_f, 'long' => value.long.to_f}
    elsif value.is_a?(Hash)
      {'lat' => value['lat'].to_f, 'long' => value['long'].to_f}
    end
  end

  def deserialize(value)
    return if value.nil?

    value.is_a?(self.class) ? value : GeoPosition.new(value['lat'], value['long'])
  end

  def initialize(lat, long)
    @lat, @long = lat.to_f, long.to_f
  end

  def [](arg)
    case arg
    when "lat"
      @lat
    when "long"
      @long
    end
  end

  def to_a
    [lat, long]
  end

  def ==(other)
    other.is_a?(self.class) && other.lat == lat && other.long == long
  end
end
