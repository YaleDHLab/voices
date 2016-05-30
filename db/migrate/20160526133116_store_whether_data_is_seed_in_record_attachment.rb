class StoreWhetherDataIsSeedInRecordAttachment < ActiveRecord::Migration
  def change
    add_column :record_attachments, :is_seed, :boolean
  end
end
