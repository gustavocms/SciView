require 'test_helper'

class S3OptionsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

end
