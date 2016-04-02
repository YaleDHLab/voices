class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.integer :cas_user_id
      t.string :title
      t.string :metadata

      t.timestamps
    end
  end
end
