class RenameFileAttachmentFields < ActiveRecord::Migration
  def change
    remove_column :record_attachments, :name
    add_column :record_attachments, :filename, :text
  end
end
