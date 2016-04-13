class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def check_privileges(requested_record)
    if requested_record.cas_user_name != session[:cas_user]
      flash[:info] = "<strong>ACCESS RESTRICTED</strong>".html_safe + ": You do not have access to this page. Please contact your administrator about your permissions."
      redirect_to user_show_path
    end
  end
end
