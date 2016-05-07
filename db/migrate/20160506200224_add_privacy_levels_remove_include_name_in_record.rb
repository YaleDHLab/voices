class AddPrivacyLevelsRemoveIncludeNameInRecord < ActiveRecord::Migration
  def change
    add_column :records, :make_private, :boolean
    remove_column :records, :include_name
  end
end
