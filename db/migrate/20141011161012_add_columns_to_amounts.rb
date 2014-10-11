class AddColumnsToAmounts < ActiveRecord::Migration
  def change
    add_column :amounts, :can_have_spares, :boolean
    add_column :amounts, :must_have_value, :boolean
  end
end
