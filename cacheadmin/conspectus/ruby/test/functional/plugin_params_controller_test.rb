require File.dirname(__FILE__) + '/../test_helper'

class PluginParamsControllerTest < ActionController::TestCase

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_plugin_param
    assert_difference('PluginParam.count') do
      post :create, :plugin_param => { }
    end

    assert_redirected_to plugin_param_path(assigns(:plugin_param))
  end

  def test_should_get_edit
    get :edit, :id => plugin_params(:one).id
    assert_response :success
  end

  def test_should_update_plugin_param
    put :update, :id => plugin_params(:one).id, :plugin_param => { }
    assert_redirected_to plugin_param_path(assigns(:plugin_param))
  end

  def test_should_destroy_plugin_param
    assert_difference('PluginParam.count', -1) do
      delete :destroy, :id => plugin_params(:one).id
    end

    assert_redirected_to plugin_params_path
  end
end
