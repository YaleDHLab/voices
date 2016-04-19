class AddHashtagsToRecord < ActiveRecord::Migration
  def change
    add_column :records, :hashtag, :text
  end
end
