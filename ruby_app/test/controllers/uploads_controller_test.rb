require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
end

class UploadsControllerNoUserTest < ActionController::TestCase
  before { @controller = UploadsController.new }
  test 'new redirects' do
    get :new
    assert_response :redirect
  end
end
