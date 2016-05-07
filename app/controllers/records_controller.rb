class RecordsController < ApplicationController
  
  # before any method in the records controller is called,
  # ensure the user is authenticated
  before_filter CASClient::Frameworks::Rails::Filter

  before_action :set_record, only: [:show, :edit, :update, :annotate, :destroy]
  
  # before serving user with a record, validate that they have permission
  # to access that record
  before_action only: [:show, :edit, :update, :destroy] do
    requested_record = Record.find_by(id: params[:id])
    check_user_privileges(requested_record)
  end

  before_action only: [:index] do
    check_admin_privileges()
  end

  # GET /records
  # GET /records.json
  def index
    @records = Record.all
  end

  # GET /records/1
  # GET /records/1.json
  def show
    @record_id = params[:id]

    # run the where clause globally
    @relevant_record = Record.find(@record_id)
    @relevant_attachments = RecordAttachment.where(record_id: @record_id).order("id")

    # make the record attachments an array if it isn't already 
    if @relevant_attachments.length > 1
      @record_attachments = @relevant_attachments
    else 
      @record_attachments = [@relevant_attachments[0]]
    end

    respond_to do |format|
      format.html {}
      format.json { render json: {
        record: @relevant_record, 
        attachments: @record_attachments,
      }.to_json }
    end
  end


  # GET /records/new
  def new
    # when user loads the new record page, delete any record attachments they have that
    # don't belong to a record (to clear out any attachments they added before a page reload)
    RecordAttachment.where(cas_user_name: session[:cas_user]).where("record_id IS?", nil).destroy_all
    @record = Record.new
  end


  # GET /records/1/edit
  def edit
    @record = Record.find(params[:id])
    @saved_date = @record.date
    @record_id = params[:id]
    @current_page = params[:page].to_i

    # run the where clause globally
    @relevant_attachments = RecordAttachment.where(record_id: @record_id).order("id")
  end

  # POST /records
  # POST /records.json
  def create
    # retrieve the current cas user name from the session hash
    @form_params = record_params()
    @form_params[:cas_user_name] = session[:cas_user]
    @record = Record.create( @form_params )

    # if the user just uploaded multiple attachments, send special flash
    # requesting the user to annotate each image
    @attachment_count = 0

    respond_to do |format|
      if @record.save

        # if the record was successfully saved, find of the current user's
        # RecordAttachment objects, then find the subset that have nil for a 
        # record_id, and set the record_id of each to the id of the current
        # record
        @attachment_count = RecordAttachment.where(cas_user_name: session[:cas_user]).where("record_id IS?", nil).update_all(:record_id => @record.id)

        # if user saves more than one record, send them to the annotate page, else to the show page
        if @attachment_count > 1
          flash[:info] = "<strong>FOR BULK UPLOADS</strong>".html_safe +
          ": Please say something about each item in this collection in the caption field."

          # send user to the record they just created, and initialize their view to page 1
          format.html { redirect_to controller: 'records', action: 'annotate', id: @record.id }
          format.json { render action: 'show', 
            status: :created, location: @record }

        else
          flash[:success] = "<strong>CONFIRMATION</strong>".html_safe + 
          ": Thank you for your contribution to the archive."

          # send user to the record they just created, and initialize their view to page 1
          format.html { redirect_to controller: 'records', action: 'show', id: @record.id }
          format.json { render action: 'show', 
            status: :created, location: @record }
        end

      else
        format.html { render action: 'new' }
        format.json { render json: @record.errors, 
          status: :unprocessable_entity }
      end
    end
  end


  # GET /annotate
  def annotate
  end


  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    respond_to do |format|
      if @record.update(record_params)

        # save any new record attachments the user wants to associate with this record
        RecordAttachment.where(cas_user_name: session[:cas_user]).where("record_id IS?", nil).update_all(:record_id => @record.id)

        flash[:success] = "<strong>Confirmation</strong>".html_safe + 
          ": Record successfully updated."
        format.html { redirect_to @record }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @record.errors, 
          status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record.destroy
    respond_to do |format|
      flash[:success] = "<strong>Confirmation</strong>".html_safe + 
        ": Record successfully deleted."
      format.html { redirect_to user_show_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_record
      begin
        found_record = Record.find(params[:id])
        @record = found_record
      rescue
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    # Never trust parameters from the scary internet, 
    # only allow the white list through.
    def record_params
      params.require(:record).permit(
        :cas_user_name, :make_private, :title,
        :description, :date, :location, :source_url, 
        :hashtag, :release_checked,
        :record_attachments
      )
    end

end
