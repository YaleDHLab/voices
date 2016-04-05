class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def show
    # retrieve all records that belong to this user
    @user_records = Record.where(cas_user_name: session[:cas_user])
  end

  # log user out of cas session
  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

end
