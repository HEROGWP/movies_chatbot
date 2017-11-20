class AddDescriptionToTheater < ActiveRecord::Migration[5.1]
  def change
    add_column :theaters, :description, :string
  end
end
