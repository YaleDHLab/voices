require 'test_helper'

class UserControllerTest < ActionController::TestCase
  setup do

    # add pseudo authentication so the tests don't break
    CASClient::Frameworks::Rails::Filter.fake("homer")
  end

  test "should get show" do
    if session[:cas_user]
      get :show
      assert_response :success
    end
  end

end
