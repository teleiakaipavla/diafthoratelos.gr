Fabricator(:search) do
  name {sequence(:name) {|i| "search #{i}" }}
  query {Faker::Lorem.sentence}
  group
  user
end
