class AddFieldsToFlaggedRecordsTable < ActiveRecord::Migration
  def change
    add_column :flagged_records, :flagging_agent, :string
    add_column :flagged_records, :flagged_record_id, :integer
  end
end
