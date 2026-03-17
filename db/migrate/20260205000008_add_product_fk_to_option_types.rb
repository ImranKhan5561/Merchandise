class AddProductFkToOptionTypes < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :option_types, :products
  end
end
