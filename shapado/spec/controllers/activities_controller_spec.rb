require 'spec_helper'

describe ActivitiesController do
  include Devise::TestHelpers

  before(:each) do
    @group = stub_group
    @user = Fabricate(:user)
    @group.add_member(@user, "owner")
    stub_authentication @user
  end

  describe "GET index" do
    it "assigns all activities as @activities" do
      activities = @group.activities.order(:created_at.desc).page
      get :index
      assigns(:activities).should eq(activities)
    end
  end
end
