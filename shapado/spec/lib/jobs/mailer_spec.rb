require 'spec_helper'

describe Jobs::Mailer do
  before(:each) do
    @current_user = Fabricate(:user)
    Thread.current[:current_user] = @current_user
    @question = Fabricate(:question)
    @group = @question.group
    @answer = Fabricate(:answer, :question => @question)
  end

  describe "on_ask_question" do
  end

  describe "on_new_comment" do
    it "should not raise an error" do
      comment = Fabricate(:comment, :commentable => @question, :user => @current_user)
      expect {Jobs::Mailer.on_new_comment(@question.id, 'Question', comment.id)}.to_not raise_error
    end
  end

  describe "on_favorite_answer" do
  end

  describe "on_follow" do
  end

  describe "on_new_invitation" do
  end
end
