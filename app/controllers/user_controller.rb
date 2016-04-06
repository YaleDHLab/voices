class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  helper_method :is_image?, :is_video?, :is_audio?

  def show
    # retrieve all records that belong to this user
    @user_records = Record.where(cas_user_name: session[:cas_user])
  end

  def login
    redirect_to static_pages_home_path
  end

  # log user out of cas session
  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  # helper methods for the view
  def is_image?
    file_upload.content_type =~ %r(image)
  end

  def is_video?
    file_upload.content_type =~ %r(video)
  end

  def is_audio?
    file_upload.content_type =~ /\Aaudio\/.*\Z/
  end

end
