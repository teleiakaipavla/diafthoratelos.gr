require 'spec_helper'

describe CloseRequestsController do
  include Devise::TestHelpers

  before (:each) do
    @group = stub_group
    @user = Fabricate(:user)
    Thread.current[:current_user] = @user
    stub_authentication @user
    Activity.stub!(:create!)
    @question = Fabricate(:question)
    @group.questions.stub!(:find_by_slug_or_id).with(@question.id).and_return(@question)
  end

  def valid_attributes
    Fabricate.attributes_for(:close_request, :user_id => @user.id)
  end

  describe "GET 'index'" do
    it "should be successful" do
      @user.stub!(:admin?).and_return(true)
      get 'index', :question_id => @question.id
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new', :question_id => @question.id
      response.should be_success
    end
  end

  describe "POST 'create'" do
    before (:each) do
    end

    it "should be successful" do
      post 'create', :question_id => @question.id, :close_request => valid_attributes
      response.should redirect_to question_path(:id => @question.slug)
    end
  end

  describe "PUT 'update'" do
    before (:each) do
      @close_request = Fabricate(:close_request, :user_id => @user.id, :closeable => @question)
      @close_request_attrs = valid_attributes
      stub_group(@question.group)
    end

    it "should be successful" do
      put 'update', :id => @close_request.id, :question_id => @question.id,  :close_request => @close_request_attrs
      response.should redirect_to question_path(:id => @question.slug)
    end
  end

  describe "DELETE 'destroy'" do
    before (:each) do
      @close_request = Fabricate(:close_request, :user_id => @user.id, :closeable => @question)
    end

    it "should be successful" do
      delete 'destroy', :id => @close_request.id, :question_id => @question.id
      response.should redirect_to question_path(:id => @question.slug)
    end
  end
end
