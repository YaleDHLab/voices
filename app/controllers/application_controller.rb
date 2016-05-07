class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def check_user_privileges(requested_record)
    # if the requested record does not belong to the current user
    # and is private, prevent the user from accessing the record
    if (requested_record.cas_user_name != session[:cas_user]) && (requested_record.make_private == true)
      flash[:info] = "<strong>ACCESS RESTRICTED</strong>".html_safe + ": You do not have access to this page. Please contact your administrator about your permissions."
      redirect_to user_show_path
    end
  end

  def check_admin_privileges()
    site_admins = ENV["VOICES_ADMINS"].split("#")
    if not site_admins.include? session[:cas_user]
      flash[:info] = "<strong>ACCESS RESTRICTED</strong>".html_safe + ": You do not have access to this page. Please contact your administrator about your permissions."
      redirect_to user_show_path
    end
  end
  
end
