class RemoveProductIdFromOptionTypes < ActiveRecord::Migration[8.1]
  def change
    # Remove the foreign key constraint first
    remove_foreign_key :option_types, :products, if_exists: true
    
    # Remove the index
    remove_index :option_types, :product_id, if_exists: true
    
    # Remove the column
    remove_column :option_types, :product_id, :bigint
  end
end
