require 'test_helper'
require 'json'

class Api::V1::ObservationsControllerTest < ActionController::TestCase
  before { sign_in test_user }

  def view_state
    @view_state ||= ViewState.create(title: "TestViewState", charts: [])
  end

  def default_params
    { format: :json, view_state_id: view_state.id }
  end

  def observation_params
    @observation_params ||= {
      observed_at: Time.now,
      message: "This doesn't seem right!"
    }
  end

  def create_request
    post :create, default_params.merge({ observation: observation_params })
  end

  def index_request
    get :index, default_params
  end

  def json_response
    yield JSON.parse(response.body)
  end

  test 'setup' do
    assert true
  end

  test 'index' do
    index_request
    json_response { |json| json.must_be_empty }
  end

  test 'index with response' do
    create_request
    index_request 
    json_response { |json| json.count.must_equal 1 }
  end

  test 'create' do
    create_request 
    json_response { |json| json["user_id"].must_equal test_user.id }
  end
end
