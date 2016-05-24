class AddAttachedFileToRecordAttachmentsForMultimediaUploads < ActiveRecord::Migration
  def change
    add_attachment :record_attachments, :file_upload
  end
end
