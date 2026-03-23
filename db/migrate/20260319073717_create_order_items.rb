class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :variant, null: false, foreign_key: true
      t.string :product_name
      t.string :variant_sku
      t.decimal :price
      t.integer :quantity
      t.string :image_url

      t.timestamps
    end
  end
end
