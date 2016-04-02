class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :cas_user_name
      t.boolean :is_admin

      t.timestamps
    end
  end
end
