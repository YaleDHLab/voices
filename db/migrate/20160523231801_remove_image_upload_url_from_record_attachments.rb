class RemoveImageUploadUrlFromRecordAttachments < ActiveRecord::Migration
  def change
    remove_column :record_attachments, :image_upload_url
  end
end
