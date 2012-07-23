Fabricator(:group) do
  name { sequence(:name) { |i| "Group #{i}" } }
  subdomain { |group| "#{group.name.gsub(" ", "-").gsub("_", "-")[0..30]}#{rand(100)}"}
  legend {|group| "#{group.name} lengend"}
  description {|group| "#{group.name} description" }
  default_tags {["testing"]}
  state "active"
  languages ["en", "es", "fr"]
  owner(:fabricator => :user)
  notification_opts { Fabricate.build(:notification_config ) }
  activity_rate 0.0
end
