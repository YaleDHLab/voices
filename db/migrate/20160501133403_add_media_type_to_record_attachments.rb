class AddMediaTypeToRecordAttachments < ActiveRecord::Migration
  def change
    add_column :record_attachments, :media_type, :string
  end
end
