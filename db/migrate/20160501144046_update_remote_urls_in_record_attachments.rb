class UpdateRemoteUrlsInRecordAttachments < ActiveRecord::Migration
  def change
    add_column :record_attachments, :image_upload_url, :text
  end
end
