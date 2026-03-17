class CreateVariantImageSets < ActiveRecord::Migration[7.1]
  def change
    create_table :variant_image_sets do |t|
      t.references :product, null: false, foreign_key: true
      t.string :option_value_ids_key, null: false  # Sorted IDs like "12-45-78"

      t.timestamps
    end

    add_index :variant_image_sets, [:product_id, :option_value_ids_key], unique: true, name: 'idx_variant_image_sets_unique'
  end
end
