class AddCustomerIpToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :customer_ip, :string
  end
end
