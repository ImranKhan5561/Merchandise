class CreatePaymentIntents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_intents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.string :external_id         # Stripe PaymentIntent ID (pi_...)
      t.integer :amount_cents
      t.string :currency, default: "usd"
      t.string :status              # requires_payment_method, succeeded, failed...
      t.jsonb :metadata, default: {}
      t.jsonb :payment_method_details, default: {}

      t.timestamps
    end

    add_index :payment_intents, :external_id, unique: true
  end
end
