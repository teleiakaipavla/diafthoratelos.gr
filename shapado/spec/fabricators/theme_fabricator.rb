Fabricator(:theme) do
  name { sequence(:name) { |i| "Theme #{i}" } }
  group
end
