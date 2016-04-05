class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def check_privileges(requested_record)
    redirect_to "/", notice: 'You dont have enough permissions to be here' unless requested_record.cas_user_name == session[:cas_user]
  end
end
