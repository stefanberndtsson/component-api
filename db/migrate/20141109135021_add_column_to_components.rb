class AddColumnToComponents < ActiveRecord::Migration
  def change
    add_column :components, :summary, :text

    Component.reset_column_information
    Component.all.each do |component|
      summary,description = component.description.split(/\n/, 2)
      component.update_attribute(:summary, summary)
      description = description.strip if description
      component.update_attribute(:description, description)
    end
  end

end
