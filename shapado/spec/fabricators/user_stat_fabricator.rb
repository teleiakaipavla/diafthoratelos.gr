Fabricator(:user_stat) do
  answer_tags { (0..rand(10)).to_a.map {|i| "tag#{i}"} }
  question_tags { (0..rand(10)).to_a.map {|i| "tag#{i}"} }
  expert_tags { (0..rand(10)).to_a.map {|i| "tag#{i}"} }
  tag_votes { (0..rand(10)).to_a.map {|i| "tag#{i}"} }
  user
end
