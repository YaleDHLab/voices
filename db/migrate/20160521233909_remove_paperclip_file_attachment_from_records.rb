class RemovePaperclipFileAttachmentFromRecords < ActiveRecord::Migration
  def change
    remove_attachment :record_attachments, :file_upload
  end
end
