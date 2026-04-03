class AddOrderDetailsToUserAddressesAndOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :user_addresses, :full_name, :string
    add_column :user_addresses, :phone_number, :string
    add_column :user_addresses, :alternate_phone, :string
    add_column :user_addresses, :landmark, :string

    add_column :orders, :order_notes, :text
  end
end
