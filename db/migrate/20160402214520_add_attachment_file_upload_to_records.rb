class AddAttachmentFileUploadToRecords < ActiveRecord::Migration
  def self.up
    change_table :records do |t|
      t.attachment :file_upload
    end
  end

  def self.down
    remove_attachment :records, :file_upload
  end
end
