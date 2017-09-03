class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :uid
      t.integer :city_id
      t.timestamps
    end
  end
end
