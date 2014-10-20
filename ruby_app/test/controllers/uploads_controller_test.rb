require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
  before { sign_in default_user }

  test 'new' do
    get :new
    assert_response :success
  end
end

class UploadsControllerNoUserTest < ActionController::TestCase
  before { @controller = UploadsController.new }
  test 'new redirects' do
    get :new
    assert_response :redirect
  end
end
