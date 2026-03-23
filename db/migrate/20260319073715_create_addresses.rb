class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name
      t.string :mobile
      t.text :address_line
      t.string :city
      t.string :state
      t.string :country
      t.string :pincode
      t.boolean :is_default

      t.timestamps
    end
  end
end
