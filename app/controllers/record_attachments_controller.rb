class RecordAttachmentsController < ApplicationController

  before_filter CASClient::Frameworks::Rails::Filter

  # PATCH/PUT /record_attachments/1.json
  def update_annotation
    @record_attachment = RecordAttachment.find(params[:id])
    @record_attachment.update_attributes(annotation: params[:annotation])
    @record_attachment.save

    print "saved", @record_attachment.to_json
    render :nothing => true
  end

  private

end