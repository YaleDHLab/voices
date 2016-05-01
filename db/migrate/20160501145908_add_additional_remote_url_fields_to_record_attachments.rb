class AddAdditionalRemoteUrlFieldsToRecordAttachments < ActiveRecord::Migration
  def change
    remove_column :record_attachments, :image_upload_url
    add_column :record_attachments, :medium_image_url, :text
    add_column :record_attachments, :annotation_thumb_url, :text
    add_column :record_attachments, :square_thumb_url, :text
  end
end
