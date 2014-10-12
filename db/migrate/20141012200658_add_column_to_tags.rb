class AddColumnToTags < ActiveRecord::Migration
  def change
    add_column :tags, :norm, :text
  end
end
