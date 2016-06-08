require 'test_helper'

class RecordsControllerTest < ActionController::TestCase
  setup do
    @record = records(:one)
    @record_attachment = record_attachments(:one)
    @user = users(:one)

    # set an id for the record
    @record.id = 1

    # add file attachment to record attachment
    @record_attachment.file_upload = File.new("test/fixtures/sample_file.png")

    # add pseudo authentication so test can pass auth challenge
    CASClient::Frameworks::Rails::Filter.fake("homer")
  end

  test "should get index" do
    get :index

    if @user.is_admin == true
      assert_response :success
      assert_not_nil assigns(:records)
    else
      assert_redirected_to user_show_path
    end
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create record" do
    assert_difference('Record.count') do 
      post :create, record: { 
        cas_user_name: @record.cas_user_name, title: @record.title, description: @record.description,
        hashtag: @record.hashtag, release_checked: @record.release_checked,
        record_attachment: @record_attachment
      }
    end

    assert_redirected_to record_path(assigns(:record))
  end

  test "should show record" do
    if record_exists(@record.id)
      get :show, id: @record

      # we only allow individuals to access records 
      # if they created those records,
      # and if the requested record exists
      # otherwise we redirect them to the home page,
      # so verify the user created this record
      if @record.cas_user_name == session[:cas_username]
        assert_response :success
      else
        # TODO: Should ensure user can't edit other user's records
        assert_response :success
      end
    end
  end

  test "should get edit" do
    if record_exists(@record.id)  
      get :edit, id: @record.id
      # we only allow individuals to access records 
      # if they created those records,
      # and if the requested record exists
      # otherwise we redirect them to the home page,
      # so verify the user created this record
      if @record.cas_user_name == session[:cas_username]
        assert_response :success
      else 
        assert_redirected_to user_show_path
      end
    end
  end

  test "should update record" do
    if record_exists(@record.id)
      patch :update, id: @record, record: { cas_user_name: @record.cas_user_name, title: @record.title }
      
      # we only allow individuals to access records 
      # if they created those records,
      # and if the requested record exists
      # otherwise we redirect them to the home page,
      # so verify the user created this record
      if @record.cas_user_name == session[:cas_username]
        assert_redirected_to record_path(assigns(:record))
      else
        assert_redirected_to user_show_path
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
