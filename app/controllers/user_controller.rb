class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def show
    # if the user has typed a search, send them search results
    if params[:keywords].present?
      @keywords = params[:keywords]
      record_search_term = RecordSearchTerm.new(@keywords)
      @user_records = Record.where(
        record_search_term.where_clause,
        record_search_term.where_args).
      order(record_search_term.order)
    else
      # otherwise retrieve all records that belong to this user
      @user_records = Record.where(cas_user_name: session[:cas_user])
    end    

    # provide json endpoint that angular can access
    respond_to do |format|
      format.html {}
      format.json { render json: @user_records }
    end
  end

  def login
    flash[:success] = "<strong>Welcome!</strong>".html_safe + " You are logged in as " + session[:cas_user]
    redirect_to static_pages_home_path
  end

  # log user out of cas session
  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

end
