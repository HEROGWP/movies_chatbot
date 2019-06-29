class AddMovieIdToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :movie_id, :integer
    add_index :clients, :movie_id
  end
end
