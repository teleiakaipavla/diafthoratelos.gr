require 'spec_helper'

describe Jobs::Answers do
  before(:each) do
    @current_user = Fabricate(:user)
    Thread.current[:current_user] = @current_user
    @question = Fabricate(:question)
    @group = @question.group
    @answer = Fabricate(:answer, :question => @question)

    Question.stub!(:find).with(@question.id).and_return(@question)
    @question.answers.stub!(:find).with(@answer.id).and_return(@answer)

    @twitter = mock("twitter client")
    @twitter.stub(:update).with(anything)
    @answer.user.stub!(:twitter_client).and_return @twitter
    @group.stub!(:twitter_client).and_return @twitter

    @question.stub(:group).and_return(@group)

  end

  describe "on_favorite_answer" do
    it "should be successful" do
#       expect {Jobs::Answers.on_favorite_answer(@answer_id, favoriter_id, link)}.to_not raise_error
    end
  end

  describe "on_create_answer" do
    it "should be successful" do
      link = ""
      Jobs::Answers.on_create_answer(@question.id, @answer.id, link)
      expect {Jobs::Answers.on_create_answer(@question.id, @answer.id, link)}.should_not raise_error
    end
  end
end
