class AddPricingAndBrandFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :brand, :string
    add_column :products, :compare_at_price, :decimal, precision: 10, scale: 2
    add_column :products, :discount_percentage, :integer
    add_column :products, :featured, :boolean, default: false
  end
end
