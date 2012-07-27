require 'test_helper'

class PublicEntitiesControllerTest < ActionController::TestCase
  setup do
    @public_entity = public_entities(:one)
    @update = { name: 'House of Cheat' }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:public_entities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create public_entity" do
    assert_difference('PublicEntity.count') do
      post :create, public_entity: @update
    end

    assert_redirected_to public_entity_path(assigns(:public_entity))
  end

  test "should show public_entity" do
    get :show, id: @public_entity
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @public_entity
    assert_response :success
  end

  test "should update public_entity" do
    put :update, id: @public_entity, public_entity: @update
    assert_redirected_to public_entity_path(assigns(:public_entity))
  end

  test "should destroy public_entity" do
    assert_difference('PublicEntity.count', -1) do
      delete :destroy, id: @public_entity
    end

    assert_redirected_to public_entities_path
  end
end
