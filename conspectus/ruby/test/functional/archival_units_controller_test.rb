require File.dirname(__FILE__) + '/../test_helper'

class ArchivalUnitsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:archival_units)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_archival_units
    assert_difference('ArchivalUnits.count') do
      post :create, :archival_units => { }
    end

    assert_redirected_to archival_units_path(assigns(:archival_units))
  end

  def test_should_show_archival_units
    get :show, :id => archival_units(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => archival_units(:one).id
    assert_response :success
  end

  def test_should_update_archival_units
    put :update, :id => archival_units(:one).id, :archival_units => { }
    assert_redirected_to archival_units_path(assigns(:archival_units))
  end

  def test_should_destroy_archival_units
    assert_difference('ArchivalUnits.count', -1) do
      delete :destroy, :id => archival_units(:one).id
    end

    assert_redirected_to archival_units_path
  end
end
