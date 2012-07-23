require 'spec_helper'

describe Jobs::Votes do
  before(:each) do
    @current_user = Fabricate(:user)
    Thread.current[:current_user] = @current_user
    @question = Fabricate(:question)
    @answer = Fabricate(:answer, :question => @question,
                        :group => @question.group)
    @group = @question.group

    User.stub!(:find).with(@current_user.id).and_return(@current_user)
    Question.stub!(:find).with(@question.id).and_return(@question)
    Answer.stub!(:find).with(@answer.id).and_return(@answer)
    Group.stub!(:find).with(@group.id).and_return(@group)

    @twitter = mock("twitter client")
    @twitter.stub(:update).with(anything)

    @answer.stub!(:user).and_return @answer.user
    @question.stub!(:user).and_return @question.user

    @current_user.stub!(:twitter_client).and_return @twitter
    @group.stub!(:twitter_client).and_return @twitter

    @question.stub!(:group).and_return @group
    @answer.stub!(:group).and_return @group
  end

  describe "on_vote_question" do
    it "should be successful" do
      lambda {Jobs::Votes.on_vote_question(@question.id, 1, @current_user.id, @question.group.id)}.should_not raise_error
    end
  end

  describe "on_vote_answer" do
    it "should be successful" do
      lambda {Jobs::Votes.on_vote_answer(@answer.id, 1,
                                         @current_user.id,
                                         @answer.group.id)}.should_not raise_error
    end
  end
end
