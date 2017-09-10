class AddColumnPriorityToCity < ActiveRecord::Migration[5.1]
  def change
    add_column :cities, :priority, :integer, default: 100
  end
end
