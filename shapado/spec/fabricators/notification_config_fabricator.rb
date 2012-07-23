Fabricator(:notification_config) do
  give_advice { true }
  activities { true }
  reports { true }
  new_answer { true }
  questions_to_twitter { true }
  badges_to_twitter { true }
  favorites_to_twitter { true }
  answers_to_twitter { true }
  comments_to_twitter { true }
end
