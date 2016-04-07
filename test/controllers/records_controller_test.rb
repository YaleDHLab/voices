require 'test_helper'

class RecordsControllerTest < ActionController::TestCase
  setup do
    @record = records(:one)

    # add pseudo authentication so the tests don't break
    CASClient::Frameworks::Rails::Filter.fake("homer")
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create record" do
    assert_difference('Record.count') do
      post :create, record: { cas_user_name: @record.cas_user_name, metadata: @record.metadata, title: @record.title }
    end

    assert_redirected_to record_path(assigns(:record))
  end

  test "should show record" do
    get :show, id: @record  

    if record_exists(@record.id)  
      # we only allow individuals to access records 
      # if they created those records,
      # and if the requested record exists
      # otherwise we redirect them to the home page,
      # so verify the user created this record
      if @record.cas_user_name == session[:cas_username]
        assert_response :success
      else
        assert_redirected_to root_path
      end

    else
      assert_redirected_to root_path
    end
  end

  test "should get edit" do
    get :edit, id: @record

    if record_exists(@record.id)  
      # we only allow individuals to access records 
      # if they created those records,
      # and if the requested record exists
      # otherwise we redirect them to the home page,
      # so verify the user created this record
      if @record.cas_user_name == session[:cas_username]
        assert_response :success
      else 
        assert_redirected_to root_path
      end
    else
      assert_redirected_to root_path
    end
  end

  test "should update record" do
    if record_exists(@record.id)
      patch :update, id: @record, record: { cas_user_name: @record.cas_user_name, metadata: @record.metadata, title: @record.title }
      
      # we only allow individuals to access records 
      # if they created those records,
      # and if the requested record exists
      # otherwise we redirect them to the home page,
      # so verify the user created this record
      if @record.cas_user_name == session[:cas_username]
        assert_redirected_to record_path(assigns(:record))
      else
        assert_redirected_to root_path
      end
    end
  end

  test "should destroy record" do
    if @record.cas_user_name == session[:cas_username]
      assert_difference('Record.count', -1) do
        delete :destroy, id: @record
      end
    end

  end
end
