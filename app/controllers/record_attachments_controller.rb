class RecordAttachmentsController < ApplicationController

  before_filter CASClient::Frameworks::Rails::Filter

  def new
    @record_attachment = RecordAttachment.new
  end

  def create
    # add the cas username to the hash we pass to the db
    @record_attachment_params = record_attachment_params()
    @record_attachment_params[:cas_user_name] = session[:cas_user]
    @record_attachment = RecordAttachment.create( @record_attachment_params )
    render :nothing => true
  end

  # PATCH/PUT /attachments/1.json
  def update_annotation
    @record_attachment = RecordAttachment.find(params[:id])
    @record_attachment.update_attributes(annotation: params[:annotation])
    @record_attachment.save

    print "saved", @record_attachment.to_json
    render :nothing => true
  end

  # DELETE /record_attachments/1
  def destroy
    @record_attachment = RecordAttachment.find(params[:id])
    @record_attachment.destroy
    render :nothing => true
  end

  private
    def record_attachment_params
      params.require(:record_attachment).permit(:file_upload, :cas_user_name, :annotation)
    end

end