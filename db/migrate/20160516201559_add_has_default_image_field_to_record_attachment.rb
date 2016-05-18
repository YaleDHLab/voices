class AddHasDefaultImageFieldToRecordAttachment < ActiveRecord::Migration
  def change
    add_column :record_attachments, :has_default_attachment, :boolean
  end
end
