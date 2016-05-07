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

      # and all records that users have marked as open
      @public_records = Record.where(make_private: false)

      # combine those lists
      @combined_results = []

      # add each result to the array
      @user_records.each do |r|
        @combined_results << r 
      end

      @public_records.each do |r|
        @combined_results << r 
      end

      # dedupe the list
      @combined_results = @combined_results.uniq

      """expose json of the following form:

        [ 
          {
            'record': 
              {
                'id': 1, 
                'record_name': 'myname'
              }, 

             'attachments': 
              [
                {
                  'id': 1, 
                  'name': 'attachment_name'
                },
                {
                  'id': 2, 
                  'name': 'other_attachment_name'
                }
              ]
          },

          {
            'record': 
              {
                'id': 2, 
                'record_name': 'myname'
              }, 

             'attachments': 
              [
                {
                  'id': 3, 
                  'name': 'attachment_name'
                },
                {
                  'id': 4, 
                  'name': 'other_attachment_name'
                }
              ]
          }
        ]
      """

      @user_records_with_attachments = []

      @combined_results.each do |r|
        @record_attachments = RecordAttachment.where(record_id: r.id)
        @record_with_attachments = {record: r, attachments: @record_attachments}
        @user_records_with_attachments << @record_with_attachments
      end

    end

    # provide json endpoint that angular can access
    respond_to do |format|
      format.html {}
      format.json { render json: @user_records_with_attachments }
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
