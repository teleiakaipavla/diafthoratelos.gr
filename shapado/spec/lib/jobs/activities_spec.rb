require 'spec_helper'

describe Jobs::Activities do
  before(:each) do
    Thread.current[:current_user] = @current_user
    @question = Fabricate(:question)
    @answer = Fabricate(:answer, :question => @question, :group => @question.group)

    @current_user = Fabricate(:user)
    @current_user.join!(@question.group)
    @answer.user.join!(@question.group)
    @moderator = Fabricate(:user)
    @question.group.add_member(@moderator, "moderator")

    @twitter = mock("Twitter client")
    @moderator.stub!(:twitter_client).and_return(@twitter)
    @current_user.stub!(:twitter_client).and_return(@twitter)
    @question.user.stub!(:twitter_client).and_return(@twitter)
    @answer.user.stub!(:twitter_client).and_return(@twitter)
    @question.group.stub!(:twitter_client).and_return(@twitter)
  end

  describe "on_activity" do
    it "should be successful" do
      lambda {Jobs::Activities.on_activity(@question.group.id, @current_user.id)}.should_not raise_error
    end
  end

  describe "on_update_answer" do
    it "should be successful" do
      Answer.stub!(:find).with(@answer.id).and_return(@answer)
      @answer.stub!(:group).and_return(@question.group)

      @answer.stub!(:updated_by).and_return(@answer.user)
      @twitter.should_receive(:update).twice.with(anything)
      lambda {Jobs::Activities.on_update_answer(@answer.id)}.should_not raise_error
    end
  end

  describe "on_create_answer" do
    it "should be successful" do
      lambda {Jobs::Activities.on_create_answer(@answer.id)}.should_not raise_error
    end
  end

  describe "on_destroy_answer" do
    it "should be successful" do
      lambda {Jobs::Activities.on_destroy_answer(@answer.user.id, @answer.attributes)}.should_not raise_error
    end
  end

  describe "on_comment" do
    before(:each) do
      @current_user.join!(@question.group)
      @comment = Fabricate(:comment, :commentable => @answer, :user => @current_user)

      Answer.stub!(:find).with(@answer.id).and_return(@answer)

      @answer.comments.stub!(:find).with{@comment.id}.and_return @comment
      @answer.stub!(:group).and_return(@question.group)

      @comment.stub!(:user).and_return(@current_user)
    end

    it "should be successful" do
      @twitter.should_receive(:update).with(anything)

      Jobs::Activities.on_comment(@answer.id, @answer.class.to_s, @comment.id, "a_link")
      lambda {Jobs::Activities.on_comment(@answer.id, @answer.class.to_s, @comment.id, "a_link")}.should_not raise_error
    end
  end

  describe "on_follow" do
    it "should be successful" do
      lambda {Jobs::Activities.on_follow(@question.user.id, @answer.user.id, @answer.group.id)}.should_not raise_error
    end
  end

  describe "on_unfollow" do
    it "should be successful" do
      lambda {Jobs::Activities.on_unfollow(@question.user.id, @answer.user.id, @answer.group.id)}.should_not raise_error
    end
  end

  describe "on_flag" do
    before(:each) do
      Group.stub!(:find).with(@question.group.id).and_return(@question.group)
      User.stub(:find).with{@moderator.id}.and_return(@question.user)
      User.stub(:find).with{@question.user.id}.and_return(@question.user)
    end

    it "should be successful" do
      @twitter.should_receive(:update).with(anything)
      Group.stub!(:find).with(@question.group.id).and_return(@question.group)
      lambda {Jobs::Activities.on_flag(@question.user.id, @question.group.id, "spam", "path")}.should_not raise_error
    end
  end

  describe "on_rollback" do
    it "should be successful" do
      Question.stub!(:find).with(@question.id).and_return(@question)
      @group = @question.group
      @question.stub!(:group).and_return(@group)
      @question.stub!(:updated_by).and_return(@question.user)
      @twitter.should_receive(:update).with(anything)
      Jobs::Activities.on_rollback(@question.id)
      lambda {Jobs::Activities.on_rollback(@question.id)}.should_not raise_error
    end
  end

  describe "on_admin_connect" do
    it "should be successful" do
      lambda {Jobs::Activities.on_admin_connect("192.168.0.2", @answer.user.id)}.should_not raise_error
    end
  end
end
