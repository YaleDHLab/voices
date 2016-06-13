class CreateCloudWords < ActiveRecord::Migration
  def change
    create_table :cloud_words do |t|
			t.string :words, array: true

			t.timestamps null: false
		end
  end
end
