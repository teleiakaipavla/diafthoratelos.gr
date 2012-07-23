
file = File.join(Rails.root.to_s, "data", "GeoLiteCity.dat")

if !File.exist?(file)
  file = File.join(Rails.root.to_s, "shared", "GeoLiteCity.dat")
end

if File.exist?(file)
  Localize = GeoIP.new(file)
else
  puts "Missing GeoIP data. Please run '#{Rails.root.to_s}/script/update_geoip'"
end


