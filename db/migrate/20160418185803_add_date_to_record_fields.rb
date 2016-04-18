class AddDateToRecordFields < ActiveRecord::Migration
  def change
    add_column :records, :date, :text
  end
end
