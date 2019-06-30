class AddRegionToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :region, :string, after: :city_id
  end
end
