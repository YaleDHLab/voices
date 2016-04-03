class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def show
    # retrieve all records that belong to this user
    @user_uploads = Record.where(cas_user_name: session[:cas_user])
  end

end
