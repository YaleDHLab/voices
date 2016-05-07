class CreateFlaggedRecords < ActiveRecord::Migration
  def change
    create_table :flagged_records do |t|

      t.timestamps null: false
    end
  end
end
