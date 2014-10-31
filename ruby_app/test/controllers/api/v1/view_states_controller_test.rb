require 'test_helper'


class Api::V1::ViewStatesControllerTest < ActionController::TestCase
  before { sign_in default_user }

  def view_state
    @view_state ||= ViewState.create(title: "TestViewState", charts: [])
  end

  def updated_view_state
    ViewState.find(view_state)
  end

  def update_params
    {
      "id"=>"#{view_state.id}", 
      "title"=>"Updated TestViewState", 
      "charts"=>[
        {
          "title"=>"Untitled Chart", 
          "channels"=>[
            {
              "title"=>"default channel", 
              "state"=>"expanded", 
              "series"=>[]
            }
          ]
        }
      ]
    }
  end



  test 'update' do
    assert_equal view_state.charts, []
    put :update, update_params.merge({ format: :json })

    updated_view_state.tap do |vs|
      assert_equal vs.charts.count, 1
      assert_equal vs.title, "Updated TestViewState"
    end
  end
end

