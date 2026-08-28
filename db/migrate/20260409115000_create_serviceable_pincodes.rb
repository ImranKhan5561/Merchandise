class CreateServiceablePincodes < ActiveRecord::Migration[7.1]
  def change
    create_table :serviceable_pincodes do |t|
      t.string :code, null: false
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :serviceable_pincodes, :code, unique: true
  end
end
