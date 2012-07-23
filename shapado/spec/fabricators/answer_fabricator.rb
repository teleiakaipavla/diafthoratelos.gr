Fabricator(:answer) do
  body { sequence(:body) { |i| "Body #{i}: #{Faker::Lorem.paragraph}" }}
  position {{"lat" => 0, "long" => 0}}
  group
  user
  question
end
