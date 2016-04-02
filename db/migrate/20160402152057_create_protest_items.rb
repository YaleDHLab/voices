class CreateProtestItems < ActiveRecord::Migration
  def change
    create_table :protest_items do |t|
      t.integer :cas_user_id
      t.string :title
      t.string :url
      t.string :metadata_tags

      t.timestamps
    end
  end
end
