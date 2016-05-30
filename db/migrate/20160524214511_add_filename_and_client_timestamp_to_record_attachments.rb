class AddFilenameAndClientTimestampToRecordAttachments < ActiveRecord::Migration
  def change
    add_column :record_attachments, :client_side_timestamp, :string
  end
end
