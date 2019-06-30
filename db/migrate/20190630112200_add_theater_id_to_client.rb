class AddTheaterIdToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :theater_id, :integer
    add_index :clients, :theater_id
  end
end
