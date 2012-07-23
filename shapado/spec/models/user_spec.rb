require 'spec_helper'

describe User do
  before(:each) do
    @user = Fabricate(:user)
    Thread.current[:current_user] = @user
  end

  describe "module/plugin inclusions (optional)" do
  end

  describe "validations" do
  end

  describe "association" do
  end

  describe "callbacks" do
  end

  describe "named scopes" do
  end

  describe "class methods" do
    describe "User#find_for_authentication" do
      it "should get the user with his login" do
        User.find_for_authentication(:email => @user.login).should == @user
      end
    end

    describe "User#find_by_login_or_id" do

      it "should return the user with his login" do
        User.find_by_login_or_id(@user.login).should == @user
      end

      it "should return the user with his id" do
        User.find_by_login_or_id(@user.login).should == @user
      end
    end

    describe "User#find_experts" do
      it("should return @user") do
        @user.preferred_languages = ["en", "es", "fr"]
        @user.save
        @stat = Fabricate(:user_stat, :user => @user, :answer_tags => ["tag1"])
        User.find_experts(["tag1"],["en", "es", "fr"]).first.should == @user
      end

      it("should not return @user") do
        @user.preferred_languages = ["en", "es", "fr"]
        @user.save
        @stat = Fabricate(:user_stat, :user => @user, :answer_tags => ["tag1"])
        User.find_experts(["tag1"], ["en"], {:except => @user.id}).first.should_not == @user
      end
    end
  end

  describe "instance methods" do
    describe "User#display_name" do
      it "should return the user's name" do
        @user.name = "test"
        @user.display_name.should == @user.name
      end

      it "should return the user's login when the name is blank" do
        @user.display_name.should == @user.login
      end
    end

    describe "User#login=" do
      it "should downcase the login" do
        @user.login = "MEE"
        @user.login.should == "mee"
      end
    end

    describe "User#email=" do
      it "should downcase the email" do
        @user.email = "ME@example.com"
        @user.email.should == "me@example.com"
      end
    end

    describe "User#to_param" do
      it "should return the user id when the login is blank" do
        @user.login = ""
        @user.to_param.should == @user.id
      end

      it "should return the user id when the login have special charts" do
        @user.login = "jhon@doe"
        @user.to_param.should == @user.id
      end

      it "should return the user login if this have wight spaces" do
        @user.login = "jhon doe"
        @user.to_param.should == @user.login
      end
    end

    describe "User#add_preferred_tags" do
      it "should add unique tags" do
        @group = Fabricate(:group, :owner => @user)
        @user.join!(@group)
        @user.add_preferred_tags(["a", "a", "b", "c"], @group)
        @user = User.find(@user.id)
        @user.config_for(@group).preferred_tags.should == ["a", "b", "c"]
        @group.destroy
      end
    end

    describe "User#remove_preferred_tags" do
      it "remove the tags a, b" do
        @group = Fabricate(:group, :owner => @user)
        @user.add_preferred_tags(["a", "b", "c"], @group)
        @user.reload
        @user.remove_preferred_tags(["a", "b"], @group)
        @user = User.find(@user.id)
        @user.config_for(@group).preferred_tags.should == ["c"]
        @group.destroy
      end
    end

    describe "User#preferred_tags_on" do
      it "should return a,b,c tags" do
        @group = Fabricate(:group, :owner => @user)
        @user.add_preferred_tags(["a", "b", "c"], @group)
        @user = User.find(@user.id)
        @user.preferred_tags_on(@group).should == ["a", "b", "c"]
        @group.destroy
      end
    end

    describe "User#language_filter=" do
      it "should set the language filter" do
        @user.language_filter.should == "user"
        @user.language_filter= "es"
        @user.language_filter.should == "es"
      end

      it "should not set the language filter when is not a avaible filter" do
        @user.language_filter.should == "user"
        @user.language_filter= "x"
        @user.language_filter.should_not == "x"
      end
    end

    describe "User#languages_to_filter" do
      before(:each) do
        @group = Fabricate(:group, :languages => ["en","es","fr"])
      end

      it "should return the AVAILABLE_LANGUAGES" do
        @user.language_filter="any"
        @user.languages_to_filter(@group).should == @group.languages
      end

      it "should return the user's preferred languages" do
        @user.language_filter="user"
        @user.preferred_languages = ["en", "es"]
        @user.languages_to_filter(@group).should == @user.preferred_languages
      end

      it "should return the user's language filter" do
        @user.language_filter="es"
        @user.languages_to_filter(@group).should == ["es"]
      end
    end

    describe "User#is_preferred_tag?" do
      it "should return the tag" do
        @group = Fabricate(:group, :owner => @user)
        @user.add_preferred_tags(["a", "b", "c"], @group)
        @user = User.find(@user.id)
        @user.is_preferred_tag?(@group, "a").should == "a"
        @group.destroy
      end
    end

    describe "User#admin?" do
      it "should return true when the user's role is admin" do
        @user.role = "admin"
        @user.admin?.should == true
      end

      it "should return false when the user's role is not admin" do
        @user.role = "user"
        @user.admin?.should == false
      end
    end

    describe "User#age" do
      it "should return 18" do
        @user.birthday = 18.years.ago
        @user.age == 18
      end
    end

    describe "User#can_modify?" do
      it "should can modify the question" do
        Activity.stub!(:create!)
        @question = Fabricate(:question, :user => @user)
        @user.can_modify?(@question)
      end
    end

    describe "User#can_create_reward?" do
      it "return true when the question was created more than 2 days ago" do
        Activity.stub!(:create!)
        @question = Fabricate(:question, :user => @user, :created_at => 3.days.ago)
        @user.update_reputation(76, @question.group)
        @user.reload
        @user.can_create_reward?(@question).should == true
      end
    end

    describe "User#groups" do
      it "should not return groups" do
        @user.groups.should be_empty
      end

      it "should return @group" do
        @group = Fabricate(:group)
        @user.join!(@group)
        @user.groups.map(&:id).should include @group.id
      end
    end

    describe "User#member_of?" do
      before(:each) do
        @group = Fabricate(:group)
      end

      it "should return false when @user is not a member of @group" do
        @user.member_of?(@group).should be_false
      end

      it "should return true when @user is a member of @group" do
        @user.join!(@group)
        @user.member_of?(@group).should be_true
      end
    end

    describe "User#role_on" do
      before(:each) do
        @group = Fabricate(:group)
      end

      it "should return " do
        @group.add_member(@user, "moderator")
        @user.role_on(@group).should == "moderator"
      end
    end

    describe "User#owner_of?" do
    end

    describe "User#mod_of?" do
    end

    describe "User#editor_of?" do
    end

    describe "User#user_of?" do
    end

    describe "User#main_language" do
    end

    describe "User#openid_login?" do
    end

    describe "User#twitter_login?" do
    end

    describe "User#has_voted?" do
    end

    describe "User#vote_on" do
    end

    describe "User#favorite?" do
    end

    describe "User#favorite" do
    end

    describe "User#logged!" do
    end

    describe "User#on_activity" do
    end

    describe "User#activity_on" do
      it "should increment activity days for @user on @group" do
        @group = Fabricate(:group)
        @user.join!(@group)

        date = Time.now
        21.times do |i|
          @user.reload
          date += 1.day
          @user.activity_on(@group, date)
          membership = @user.config_for(@group, false)
          membership.activity_days.should == i+1
        end
      end

      it "should reset activity days for @user on @group" do
        @group = Fabricate(:group)
        @user.join!(@group)
        date = Time.now
        21.times do |i|
          @user.reload
          date += 1.day+1
          @user.activity_on(@group, date)
          @user.config_for(@group, false).activity_days.should == i+1
        end
        date += 2.days
        @user.activity_on(@group, date)
        @user.reload
        @user.config_for(@group, false).activity_days.should == 0
      end
    end

    describe "User#reset_activity_days!" do
    end

    describe "User#upvote!" do
    end

    describe "User#downvote!" do
    end

    describe "User#update_reputation" do
    end

    describe "User#reputation_on" do
    end

    describe "User#stats" do
    end

    describe "User#badges_count_on" do
    end

    describe "User#badges_on" do
    end

    describe "User#find_badge_on" do
    end

    describe "User#add_friend" do
    end

    describe "User#remove_friend" do
    end

    describe "User#followers" do
      it "When the user does not have followers" do
        friend = Fabricate(:user)
        @user.followers.count.should == 0
      end

      it "When the user have followers" do
        @group = Fabricate(:group, :owner => @user)
        @user.join!(@group)
        friend = Fabricate(:user)
        friend.join!(@group)
        friend.add_friend(@user)
        @user.friend_list.reload
        @user.followers.count.should == 1
      end
    end

    describe "User#following" do
    end

    describe "User#following?" do
    end

    describe "User#viewed_on!" do
    end

    describe "User#config_for" do
    end

    describe "User#reputation_stats" do
    end

    describe "User#has_flagged?" do
    end

    describe "User#has_requested_to_close?" do
    end

    describe "User#has_requested_to_open?" do
    end

    describe "User#generate_uuid" do
    end
  end
end
