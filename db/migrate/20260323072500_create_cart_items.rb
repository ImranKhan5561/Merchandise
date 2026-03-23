class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :variant, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
