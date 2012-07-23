require 'spec_helper'

describe Group do
  before(:each) do
    @group = Fabricate(:group)
  end

  describe "module/plugin inclusions (optional)" do
  end

  describe "validations" do
    describe " for reputation configs" do
      it "should be invalid for a undefined reputation constrains" do
        @group.reputation_constrains = {"foo" => 10}
        @group.valid?.should be_false
        @group.errors[:reputation_constrains].should_not be_nil
      end

      it "should be invalid for a undefined reputation rewards" do
        @group.reputation_rewards = {"foo" => 10}
        @group.valid?.should be_false
        @group.errors[:reputation_rewards].should_not be_nil
      end

      it "should be invalid when a reputation rewards for an acction is less than your undo action" do
        @group.reputation_rewards = { "vote_up_question" => 0, "undo_vote_up_question" => 1}
        @group.valid?.should be_false
        @group.errors[:undo_vote_up_question].should_not be_nil
      end
    end
  end

  describe "association" do
  end

  describe "callbacks" do
  end

  describe "named scopes" do
  end

  describe "class methods" do
    describe "Group#humanize_reputation_constrain" do
    end

    describe "Group#humanize_reputation_rewards" do
    end

    describe "Group#find_field_from_params" do
      before(:each) do
        @params = {}
        @request = mock("request")
        Group.stub!(:find).and_return(@group)
        @group.stub!(:has_logo?).and_return(true)
        @pattern = "/_files/groups/%1/#{@group.id}"
      end

      it "should return the @group logo" do
        @pattern.gsub!("%1", "logo")
        @group.should_receive(:logo).and_return("logo")
        @request.should_receive(:path).and_return(@pattern)
        Group.find_file_from_params(@param, @request).should == "logo"
      end

      it "should return the @group css" do
        @pattern.gsub!("%1", "css")
        css = "custom_css"
        css.stub!(:content_type=)
        @group.current_theme.should_receive(:stylesheet).and_return(css)
        @request.should_receive(:path).and_return(@pattern)
        Group.find_file_from_params(@param, @request).should == "custom_css"
      end

      it "should return the @group favicon" do
        @pattern.gsub!("%1", "favicon")
        @group.should_receive(:has_custom_favicon?).and_return(true)
        @group.should_receive(:custom_favicon).and_return("custom_favicon")
        @request.should_receive(:path).and_return(@pattern)
        Group.find_file_from_params(@param, @request).should == "custom_favicon"
      end
    end
  end

  describe "instance methods" do
    describe "Group#has_custom_domain?" do
      it "should return false for a group with a localhost.lan domain" do
        @group.domain = "ask.test.loc"
        @group.has_custom_domain?.should be_false
      end

      it "should return true for a group with a mycustom.com" do
        @group.domain = "mycustom.com"
        @group.has_custom_domain?.should be_true
      end
    end

    describe "Group#tag_list" do
      it "should fetch the group's tag_list" do
        pending
      end
    end

    describe "Group#default_tags=" do
      it "should convert the string separted by comas in an array" do
        @group.default_tags = "apples,oranges"
        @group.default_tags.should == %w[apples oranges]
      end

      it "should convert the string separted by comas and spaces in an array" do
        @group.default_tags = "apples,oranges mango"
        @group.default_tags.should == %w[apples oranges mango]
      end
    end

    describe "Group#add_member" do
      before(:each) do
        @user = Fabricate(:user)
        @user.file_list.stub!(:destroy_files)
      end

      after(:each) do
        @user.destroy
      end

      it "should add the @user as group member" do
        @group.is_member?(@user).should be_false
        @group.add_member(@user, "user")
        @group.is_member?(@user).should be_true
      end
    end

    describe "Group#is_member?" do
      before(:each) do
        @user = Fabricate(:user)
      end

      after(:each) do
        @user.destroy
      end

      it "should return false for @user" do
        @group.is_member?(@user).should be_false
      end
    end

    describe "Group#pending?" do
      it "should return true for a pending group" do
        @group.state = "pending"
        @group.pending?.should == true
      end
    end

    describe "Group#on_activity" do
      describe "should increment the group activity_rate" do
        it "in 0.1 when a new question is create" do
          current_rate = @group.activity_rate || 0.0
          @group.on_activity(:ask_question)
          @group.reload
          (@group.activity_rate-current_rate).should == 0.1
        end

        it "in 0.3 when a new answer is create" do
          current_rate = @group.activity_rate || 0.0
          @group.on_activity(:answer_question)
          @group.reload
          (@group.activity_rate-current_rate).should == 0.3
        end
      end
    end

    describe "Group#language=" do
      it "should set group language as es" do
        @group.language.should == nil
        @group.language = "es"
        @group.language.should == "es"
      end

      it "should set group language as nil" do
        @group.language = "es"
        @group.language.should == "es"
        @group.language = "none"
        @group.language.should be_nil
      end
    end
  end
end
