class AddCasUserNameToRecordAttachments < ActiveRecord::Migration
  def change
    add_column :record_attachments, :cas_user_name, :text
  end
end
