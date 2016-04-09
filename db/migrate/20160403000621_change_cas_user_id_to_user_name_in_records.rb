class ChangeCasUserIdToUserNameInRecords < ActiveRecord::Migration
  def change
    remove_column :records, :cas_user_id
    add_column :records, :cas_user_name, :string 
  end
end
