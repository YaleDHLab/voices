class AddFileUploadUrlToRecords < ActiveRecord::Migration
  def change
    add_column :records, :file_upload_url, :text
  end
end
