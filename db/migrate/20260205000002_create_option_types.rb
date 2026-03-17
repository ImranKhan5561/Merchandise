class CreateOptionTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :option_types do |t|
      t.string :name
      t.string :presentation
      t.references :product, null: true # foreign_key added in later migration to handle circular dependency

      t.timestamps
    end
  end
end
