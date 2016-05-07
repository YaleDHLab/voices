class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ###
  # Create three levels of access:
  #   users can access records they created and records others have made public
  #   only creators of objects can edit, update, and destroy those objects
  #   only admins can access the index method in records controller
  ###

  # method that grants each cas user access to records they created and records
  # others have made public
  def check_user_privileges(requested_record)
    # if the requested record does not belong to the current user
    # and is private, prevent the user from accessing the record
    if (requested_record.cas_user_name != session[:cas_user]) && (requested_record.make_private == true)
      flash[:info] = "<strong>ACCESS RESTRICTED</strong>".html_safe + ": You do not have access to this page. Please contact your administrator about your permissions."
      redirect_to user_show_path
    end
  end

  # method that grants only the creator of a record edit, update, and delete privileges
  def check_private_user_privileges(requested_record)
    # if the requested record does not belong to the current user
    # and is private, prevent the user from accessing the record
    if (requested_record.cas_user_name != session[:cas_user])
      flash[:info] = "<strong>ACCESS RESTRICTED</strong>".html_safe + ": You do not have access to this page. Please contact your administrator about your permissions."
      redirect_to user_show_path
    end
  end

  # method that grants only admins access to records#index method
  def check_admin_privileges()
    site_admins = ENV["VOICES_ADMINS"].split("#")
    if not site_admins.include? session[:cas_user]
      flash[:info] = "<strong>ACCESS RESTRICTED</strong>".html_safe + ": You do not have access to this page. Please contact your administrator about your permissions."
      redirect_to user_show_path
    end
  end
  
end
