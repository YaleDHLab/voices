class RestoreOriginalNameRecordAttachments < ActiveRecord::Migration
  def change
    rename_table :attachments, :record_attachments
  end
end
