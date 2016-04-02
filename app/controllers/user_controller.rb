class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  
  def login
  end

  def submit
  end
end
