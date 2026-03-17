class AddIsVisualToProductOptionTypes < ActiveRecord::Migration[7.1]
  def change
    add_column :product_option_types, :is_visual, :boolean, default: false
  end
end
