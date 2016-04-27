class RecordsController < ApplicationController
  
  # before any method in the records controller is called,
  # ensure the user is authenticated
  before_filter CASClient::Frameworks::Rails::Filter

  before_action :set_record, only: [:show, :edit, :update, :destroy]
  
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
  end

  # GET /records/new
  def new
    @record = Record.new
  end

  # GET /records/1/edit
  def edit
    @record = Record.find(params[:id])
    @include_user_name = should_include_user_name?(params[:id])
    @saved_date = @record.date
  end

  # POST /records
  # POST /records.json
  def create
    # retrieve the current cas user name from the session hash
    

    #@record.cas_user_name = session[:cas_user]

    @record = Record.create(record_params)

    
    #respond_to do |format|
    #  if @record.save
    #    flash[:success] = "<strong>CONFIRMATION</strong>".html_safe + 
    #      ": Thank you for your contribution to the archive."
    #    format.html { redirect_to @record }
    #    format.json { render action: 'show', 
    #      status: :created, location: @record }
    #  else
    #    format.html { render action: 'new' }
    #    format.json { render json: @record.errors, 
    #      status: :unprocessable_entity }
    #  end
    #end
    

  end

  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    respond_to do |format|
      if @record.update(record_params)
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
        :cas_user_name, :include_name, :title, :content_type, 
        :file_upload, :description, :date, :location, 
        :source_url, :hashtag, :metadata, :release_checked
      )
    end

    # Determine whether user wants to include their name 
    # alongside the record
    def should_include_user_name?(record_id)
      raw_boolean = Record.find(record_id).include_name
      if raw_boolean == true
        return 1
      end
      return 0
    end

end
