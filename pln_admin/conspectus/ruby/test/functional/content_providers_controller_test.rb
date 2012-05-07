require File.dirname(__FILE__) + '/../test_helper'

class ContentProvidersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:content_providers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_content_provider
    assert_difference('ContentProvider.count') do
      post :create,   :content_provider => { :name => "University Somewhere Library", 
        :plugin_prefix => "edu.uni.library", 
        :icon_url => "/images/content_providers/aub.ico"}
    end
    
    assert_redirected_to content_provider_path(assigns(:content_provider))
  end

  def test_should_show_content_provider
    get :show, :id => content_providers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => content_providers(:one).id
    assert_response :success
  end

  def test_should_update_content_provider
    put :update, :id => content_providers(:one).id, :content_provider => { }
    assert_redirected_to content_provider_path(assigns(:content_provider))
  end

  def test_should_destroy_content_provider
    assert_difference('ContentProvider.count', -1) do
      delete :destroy, :id => content_providers(:one).id
    end

    assert_redirected_to content_providers_path
  end
end
