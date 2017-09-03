class CreateClientTheaterShips < ActiveRecord::Migration[5.1]
  def change
    create_table :client_theater_ships do |t|
      t.integer :client_id
      t.integer :theater_id
      t.timestamps
    end
  end
end
