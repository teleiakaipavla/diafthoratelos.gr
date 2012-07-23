Fabricator(:question) do
  title { Faker::Lorem.sentence}
  position {{"lat" => 0, "long" => 0}}
  group
  user
end
