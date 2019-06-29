class CreateTimeTables < ActiveRecord::Migration[5.1]
  def change
    create_table :time_tables do |t|
      t.string :theater_type
      t.integer :theater_id
      t.integer :movie_id
      t.datetime :start_time

      t.timestamps
    end

    add_index :time_tables, :theater_id
    add_index :time_tables, :movie_id
    add_index :time_tables, :start_time
  end
end
