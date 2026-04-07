module Api
  class PaymentIntentsController < ApplicationController
    before_action :authenticate_user!

    def create
      order = current_user.orders.find(params[:order_id])

      # Reuse an existing pending/unconfirmed payment intent if one exists
      existing = order.payment_intent

      if existing
        begin
          stripe_intent = Stripe::PaymentIntent.retrieve(existing.external_id)
          render json: { client_secret: stripe_intent.client_secret, payment_intent_id: existing.external_id }
          return
        rescue Stripe::StripeError => e
          Rails.logger.error "Failed to retrieve existing Stripe intent: #{e.message}"
          existing.destroy
        end
      end

      amount_cents = (order.total_amount * 100).to_i

      stripe_intent = Stripe::PaymentIntent.create(
        {
          amount: amount_cents,
          currency: "usd",
          automatic_payment_methods: { enabled: true },
          metadata: {
            order_id: order.id,
            user_id: current_user.id,
            order_number: order.order_number
          }
        },
        { idempotency_key: "order_#{order.id}_#{order.updated_at.to_i}" }
      )

      PaymentIntent.create!(
        external_id: stripe_intent.id,
        amount_cents: amount_cents,
        currency: "usd",
        status: stripe_intent.status,
        user: current_user,
        order: order,
        metadata: stripe_intent.metadata.to_h
      )

      render json: { client_secret: stripe_intent.client_secret, payment_intent_id: stripe_intent.id }

    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error for order #{params[:order_id]}: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Order not found" }, status: :not_found
    end
  end
end
