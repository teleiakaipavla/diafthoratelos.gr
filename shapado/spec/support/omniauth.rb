OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:facebook] = {
  "credentials"=>{"token"=> "htyu2786666ootpr5"},
  "uid" => "9876543210",
  "provider" => "facebook",
  "user_info" => {"email" => "john@facebook.com", "urls" => {"Facebook"=>"http://www.facebook.com/johnDoe", "Website"=>nil}}
}

OmniAuth.config.mock_auth[:twitter] = {
  "uid" => "9874356787",
  "provider" => "twitter",
  "user_info" => {"nickname" => "johnDoe"},
  "credentials"=>{"token"=>"jth36yjei825435", "secret"=>"jth36yjei825435"}
}
