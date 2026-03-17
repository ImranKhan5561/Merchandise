class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.references :category, null: false, foreign_key: true
      t.decimal :base_price, precision: 10, scale: 2
      t.integer :total_stock
      t.string :product_type
      t.boolean :active, default: true
      t.references :visual_option_type, null: true, foreign_key: { to_table: :option_types }

      t.timestamps
    end
    add_index :products, :slug, unique: true
  end
end
