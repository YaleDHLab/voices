class RenameRecordAttachment < ActiveRecord::Migration
  def change
    rename_table :record_attachments, :attachments
  end
end
