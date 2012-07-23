require 'spec_helper'

describe ThemesController do
  include Devise::TestHelpers

  before(:each) do
    @group = stub_group
    @user = Fabricate(:user)
    @group.add_member(@user, "owner")
    stub_authentication @user
  end

  def valid_attributes
    Fabricate.attributes_for(:theme)
  end

  describe "GET index" do
    it "assigns all themes as @themes" do
      themes = @group.themes
      get :index
      assigns(:themes).to_a.should eq(themes)
    end
  end

  describe "GET show" do
    it "assigns the requested theme as @theme" do
      theme = Theme.create! valid_attributes
      get :show, :id => theme.id.to_s
      assigns(:theme).should eq(theme)
    end
  end

  describe "GET new" do
    it "assigns a new theme as @theme" do
      get :new
      assigns(:theme).should be_a_new(Theme)
    end
  end

  describe "GET edit" do
    it "assigns the requested theme as @theme" do
      theme = Fabricate(:theme, :group => @group)
      get :edit, :id => theme.id.to_s
      assigns(:theme).should eq(theme)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Theme" do
        expect {
          post :create, :theme => valid_attributes
        }.to change(Theme, :count).by(1)
      end

      it "assigns a newly created theme as @theme" do
        post :create, :theme => valid_attributes
        assigns(:theme).should be_a(Theme)
        assigns(:theme).should be_persisted
      end

      it "redirects to the created theme" do
        post :create, :theme => valid_attributes
        response.should redirect_to(Theme.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved theme as @theme" do
        # Trigger the behavior that occurs when invalid params are submitted
        Theme.any_instance.stub(:save).and_return(false)
        post :create, :theme => {}
        assigns(:theme).should be_a_new(Theme)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Theme.any_instance.stub(:save).and_return(false)
        post :create, :theme => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested theme" do
        theme = Theme.create! valid_attributes
        # Assuming there are no other themes in the database, this
        # specifies that the Theme created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Theme.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => theme.id, :theme => {'these' => 'params'}
      end

      it "assigns the requested theme as @theme" do
        theme = Theme.create! valid_attributes
        put :update, :id => theme.id, :theme => valid_attributes
        assigns(:theme).should eq(theme)
      end

      it "redirects to the theme" do
        theme = Theme.create! valid_attributes
        put :update, :id => theme.id, :theme => valid_attributes
        response.should redirect_to(theme)
      end
    end

    describe "with invalid params" do
      it "assigns the theme as @theme" do
        theme = Theme.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Theme.any_instance.stub(:save).and_return(false)
        put :update, :id => theme.id.to_s, :theme => {}
        assigns(:theme).should eq(theme)
      end

      it "re-renders the 'edit' template" do
        theme = Theme.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Theme.any_instance.stub(:save).and_return(false)
        put :update, :id => theme.id.to_s, :theme => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested theme" do
      theme = Fabricate(:theme, valid_attributes.merge(:group => @group))
      expect {
        delete :destroy, :id => theme.id.to_s
      }.to change(Theme, :count).by(-1)
    end

    it "redirects to the themes list" do
      theme = Fabricate(:theme, valid_attributes.merge(:group => @group))
      delete :destroy, :id => theme.id.to_s
      response.should redirect_to(themes_url)
    end
  end

end
