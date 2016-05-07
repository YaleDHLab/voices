class RestoreMakePrivateName < ActiveRecord::Migration
  def change
    remove_column :records, :make_public
    add_column :records, :make_private, :boolean
  end
end
