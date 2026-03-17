class CreateJoinTableOptionValuesVariants < ActiveRecord::Migration[8.1]
  def change
    create_join_table :option_values, :variants do |t|
      t.index [:variant_id, :option_value_id]
      t.index [:option_value_id, :variant_id]
    end
  end
end
