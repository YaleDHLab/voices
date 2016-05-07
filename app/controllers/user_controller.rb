class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def show
    # users have access to records they've uploaded and non-private records
    # populate a collection of searchable records
    @user_records = Record.where("make_private = ? OR cas_user_name = ?", false, session[:cas_user])

    if params[:keywords].present?
      @keywords = params[:keywords]

      # create a new search query
      record_search_term = RecordSearchTerm.new(@keywords)
      
      # retrieve the records to display to the user
      @records_to_display = @user_records.where(
        record_search_term.where_clause,
        record_search_term.where_args).
      order(record_search_term.order).uniq

    else
      # otherwise retrieve all records that belong to this user
      @records_to_display = @user_records 
    end


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

    @records_to_display.each do |r|
      @record_attachments = RecordAttachment.where(record_id: r.id)
      @record_with_attachments = {record: r, attachments: @record_attachments}
      @user_records_with_attachments << @record_with_attachments
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
