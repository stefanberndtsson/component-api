class CreateComponentTags < ActiveRecord::Migration
  def change
    create_table :component_tags do |t|
      t.integer :component_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
