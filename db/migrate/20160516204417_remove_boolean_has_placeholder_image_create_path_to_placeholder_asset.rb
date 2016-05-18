class RemoveBooleanHasPlaceholderImageCreatePathToPlaceholderAsset < ActiveRecord::Migration
  def change
    remove_column :record_attachments, :has_default_attachment
    add_column :record_attachments, :default_attachment_path, :string
  end
end
