require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
  before { sign_in test_user }

  test 'new' do
    get :new
    assert_response :success
  end

  test 'create' do
    post :create, csv: fixture_file_upload('test_data.csv')
    assert_response :redirect
  end
end

class UploadsControllerNoUserTest < ActionController::TestCase
  before { @controller = UploadsController.new }
  test 'new redirects' do
    get :new
    assert_response :redirect
  end
end
