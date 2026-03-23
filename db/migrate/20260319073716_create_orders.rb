class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :order_number
      t.integer :status
      t.integer :payment_status
      t.string :payment_method
      t.decimal :subtotal
      t.decimal :tax
      t.decimal :shipping_fee
      t.decimal :total_amount
      t.string :shipping_name
      t.string :shipping_phone
      t.string :shipping_address
      t.string :shipping_city
      t.string :shipping_state
      t.string :shipping_country
      t.string :shipping_pincode

      t.timestamps
    end
    add_index :orders, :order_number
  end
end
