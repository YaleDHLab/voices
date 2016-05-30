class AddFileFieldsToRecordAttachment < ActiveRecord::Migration
  def change
    add_column :record_attachments, :mimetype, :string
    add_column :record_attachments, :name, :text
  end
end
