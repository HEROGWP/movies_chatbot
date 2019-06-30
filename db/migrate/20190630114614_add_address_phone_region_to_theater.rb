class AddAddressPhoneRegionToTheater < ActiveRecord::Migration[5.1]
  def change
    add_column :theaters, :address, :string, after: :name
    add_column :theaters, :phone, :string, after: :name
    add_column :theaters, :region, :string, after: :name
  end
end
