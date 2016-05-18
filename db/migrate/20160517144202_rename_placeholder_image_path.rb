class RenamePlaceholderImagePath < ActiveRecord::Migration
  def change
    remove_column :record_attachments, :default_attachment_path
    add_column :record_attachments, :placeholder_image_path, :string
  end
end
