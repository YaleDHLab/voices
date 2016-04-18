class AddIndexesToRecords < ActiveRecord::Migration
  def change
    execute %{
      CREATE INDEX
        records_lower_description
      ON
        records (lower(description) varchar_pattern_ops)
    }
    execute %{
      CREATE INDEX
        records_lower_title
      ON
        records (lower(title) varchar_pattern_ops)
    } 
  end
end
