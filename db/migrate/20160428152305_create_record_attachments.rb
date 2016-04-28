class CreateRecordAttachments < ActiveRecord::Migration
  def change
    create_table :record_attachments do |t|

      t.timestamps null: false
    end
  end
end
