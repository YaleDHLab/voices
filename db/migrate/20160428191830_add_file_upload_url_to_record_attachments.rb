class AddFileUploadUrlToRecordAttachments < ActiveRecord::Migration
  def change
    add_column :record_attachments, :file_upload_url, :text
  end
end
