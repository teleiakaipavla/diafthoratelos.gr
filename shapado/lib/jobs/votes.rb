module Jobs
  class Votes
    extend Jobs::Base

    def self.on_vote_question(question_id, value, user_id, group_id)
      question = Question.find(question_id)

      group = Group.find(group_id)
      user = User.find(user_id)

      if vuser = question.user
        if value == 1
          create_badge(vuser, group, :token => "student", :source => question, :unique => true)
        end

        if question.votes_average >= 10
          create_badge(vuser, group, {:token => "nice_question", :source => question}, {:unique => true, :source_id => question.id})
        end

        if question.votes_average >= 25
          create_badge(vuser, group, {:token => "good_question", :source => question}, {:unique => true, :source_id => question.id})
        end

        if question.votes_average >= 100
          create_badge(vuser, group, {:token => "great_question", :source => question}, {:unique => true, :source_id => question.id})
        end
      end

      on_vote(question, value, user, group)
      on_vote_user(question, value, user, group)
    end

    def self.on_vote_answer(answer_id, value, user_id, group_id)
      answer = Answer.find(answer_id)

      group = Group.find(group_id)
      user = User.find(user_id)

      if vuser = answer.user
        if answer.votes_average >= 10
          create_badge(vuser, group, {:token => "nice_answer", :source => answer}, {:unique => true, :source_id => answer.id})
        end

        if answer.votes_average >= 25
          create_badge(vuser, group, {:token => "good_answer", :source => answer}, {:unique => true, :source_id => answer.id})
        end

        if answer.votes_average >= 100
          create_badge(vuser, group, {:token => "great_answer", :source => answer}, {:unique => true, :source_id => answer.id})
        end

        if (answer.created_at - answer.question.created_at) >= 60.days && answer.votes_average >= 5
          create_badge(vuser, group, {:token => "necromancer", :source => answer}, {:unique => true, :source_id => answer.id})
        end

        if vuser.id == answer.question.user_id && answer.votes_average >= 3
          create_badge(vuser, group, {:token => "self-learner", :source => answer, :unique => true})
        end
        if value == 1
          stats = vuser.stats(:tag_votes)
          tags = answer.question.tags
          tokens = Set.new(Badge.TOKENS)
          tags.delete_if { |t| tokens.include?(t) }

          stats.vote_on_tags(tags)

          tags.each do |tag|
            next if stats.tag_votes[tag].blank?

            badge_type = nil
            votes = stats.tag_votes[tag]+1
            if votes >= 200 && votes < 400
              badge_type = "bronze"
            elsif votes >= 400 && votes < 1000
              badge_type = "silver"
            elsif votes >= 1000
              badge_type = "gold"
            end

            if badge_type && vuser.find_badge_on(group, tag, :type => badge_type).nil?
              create_badge(vuser, group, :token => tag, :type => badge_type, :source => answer, :for_tag => true)
            end
          end
        end
      end

      on_vote(answer, value, user, group)
      on_vote_user(answer, value, user, group)
    end

    private
    def self.on_vote(voteable, value, user, group)
      if value == -1
        create_badge(user,  group,  :token => "critic", :source => voteable, :unique => true)
      else
        create_badge(user, group, :token => "supporter", :source => voteable, :unique => true)
      end

      membership = user.config_for(group)
      if membership && membership.views_count >= 10000
        create_badge(user, group, :token => "popular_person", :unique => true)
      end

      if (Answer.where("votes.#{user.id}" => {:$exists => true}).count +
         Question.where("votes.#{user.id}" => {:$exists => true}).count) >= 300
        create_badge(user, group, :token => "civic_duty", :unique => true)
      end
    end

    def self.on_vote_user(voteable, value, user, group)
      vuser = voteable.user
      return if vuser.nil?

      membership = vuser.config_for(group)
      vote_value = membership ? membership.votes_up : 0

      if vote_value >= 100
        create_badge(vuser, group, :token => "effort_medal",  :source => voteable, :unique => true)
      end

      if vote_value >= 200
        create_badge(vuser, group, :token => "merit_medal", :source => voteable, :unique => true)
      end

      if vote_value >= 300
        create_badge(vuser,  group, :token => "service_medal", :source => voteable, :unique => true)
      end

      if vote_value >= 500 && vuser.config_for(group).votes_down <= 10
        create_badge(vuser, group, :token => "popstar", :source => voteable, :unique => true)
      end

      if vote_value >= 1000 && vuser.config_for(group).votes_down <= 10
        create_badge(vuser, group, :token => "rockstar",  :source => voteable, :unique => true)
      end
    end
  end
end
