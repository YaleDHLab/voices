class AddImageUploadUrlToRecordAttachmentsAndRemoveLegacyImageUrls < ActiveRecord::Migration
  def change
    add_column :record_attachments, :image_upload_url, :text
    remove_column :record_attachments, :medium_image_url
    remove_column :record_attachments, :annotation_thumb_url
    remove_column :record_attachments, :square_thumb_url
  end
end
