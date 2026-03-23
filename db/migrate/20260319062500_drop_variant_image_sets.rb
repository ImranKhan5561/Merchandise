class DropVariantImageSets < ActiveRecord::Migration[7.1]
  def change
    drop_table :variant_image_sets do |t|
      t.references :product, null: false, foreign_key: true
      t.string :option_value_ids_key, null: false

      t.timestamps
      t.index [:product_id, :option_value_ids_key], unique: true, name: 'idx_variant_image_sets_unique'
    end
  end
end
