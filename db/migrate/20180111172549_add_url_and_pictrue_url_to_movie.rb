class AddUrlAndPictrueUrlToMovie < ActiveRecord::Migration[5.1]
  def change
    add_column :movies, :url, :string
    add_column :movies, :picture_url, :string
  end
end
