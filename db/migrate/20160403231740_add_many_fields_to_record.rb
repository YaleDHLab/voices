class AddManyFieldsToRecord < ActiveRecord::Migration
  def change
    add_column :records, :include_name, :boolean
    add_column :records, :content_type, :string
    add_column :records, :description, :text
    add_column :records, :location, :string
    add_column :records, :source_url, :string
    add_column :records, :release_cheeked, :boolean
  end
end
