Fabricator(:user) do
  login {sequence(:login) { |i| "user#{i}" }}
  email {Faker::Internet.email}
  password "test123"
  password_confirmation "test123"
  position {{"lat" => 0, "long" => 0}}
  avatar {StringIO.new("MOCK")}
  notification_opts { Fabricate.build(:notification_config ) }
end
