require 'test_helper'

class ContactFormsControllerTest < ActionController::TestCase
  setup do
    @contact_form = contact_forms(:one)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contact_form" do
    assert_difference('ContactForm.count') do
      post :create, contact_form: { message: @contact_form.message }
    end
    assert_redirected_to root_path
  end

end
