class CreateRelationshipBetwenRecordAndAttachment < ActiveRecord::Migration
  def change
    add_column :record_attachments, :record_id, :integer   
    add_column :record_attachments, :annotation, :text
    
    remove_attachment :records, :file_upload
    add_attachment :record_attachments, :file_upload

  end
end
