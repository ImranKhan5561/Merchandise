module Api
  class StripeWebhooksController < ApplicationController
    # Skip CSRF and authentication — Stripe calls this directly
    skip_before_action :verify_authenticity_token, raise: false
    skip_before_action :authenticate_user!, raise: false

    def create
      payload    = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]

      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
      rescue JSON::ParserError => e
        Rails.logger.error "Stripe webhook JSON parse error: #{e.message}"
        render json: { error: "Invalid payload" }, status: 400
        return
      rescue Stripe::SignatureVerificationError => e
        Rails.logger.error "Stripe webhook signature verification failed: #{e.message}"
        render json: { error: "Invalid signature" }, status: 400
        return
      end

      Rails.logger.info "🎯 Stripe event received: #{event.type}"

      case event.type
      when "payment_intent.succeeded"
        handle_payment_success(event.data.object)
      when "payment_intent.payment_failed"
        handle_payment_failed(event.data.object)
      when "charge.succeeded"
        handle_charge_success(event.data.object)
      when "charge.updated"
        charge = event.data.object
        handle_charge_success(charge) if charge.status == "succeeded" && charge.paid
      else
        Rails.logger.info "Unhandled Stripe event: #{event.type}"
      end

      render json: { received: true }
    end

    private

    def handle_payment_success(payment_intent)
      update_order_from_intent(payment_intent.id, status: :paid)
    end

    def handle_charge_success(charge)
      payment_intent_id = charge.payment_intent
      return unless payment_intent_id

      record = PaymentIntent.find_by(external_id: payment_intent_id)
      return unless record

      payment_details = {
        charge_id:      charge.id,
        receipt_url:    charge.receipt_url,
        card_last4:     charge.payment_method_details&.card&.last4,
        card_brand:     charge.payment_method_details&.card&.brand,
        card_exp_month: charge.payment_method_details&.card&.exp_month,
        card_exp_year:  charge.payment_method_details&.card&.exp_year,
        paid_at:        Time.current
      }

      ActiveRecord::Base.transaction do
        record.update!(
          status: "succeeded",
          payment_method_details: payment_details,
          metadata: record.metadata.merge(
            "stripe_charge_id"    => charge.id,
            "stripe_receipt_url" => charge.receipt_url
          )
        )

        record.order.update!(payment_status: :paid, status: :pending)
      end

      broadcast_order_update(record.order)
      Rails.logger.info "✅ Order #{record.order.id} confirmed via charge webhook"
    end

    def handle_payment_failed(payment_intent)
      record = PaymentIntent.find_by(external_id: payment_intent.id)
      return unless record

      ActiveRecord::Base.transaction do
        record.update!(status: "failed")
        record.order.update!(payment_status: :failed, status: :cancelled)
      end

      broadcast_order_update(record.order)
      Rails.logger.info "❌ Order #{record.order.id} marked as failed"
    rescue => e
      Rails.logger.error "Failed to handle payment failure: #{e.message}"
      raise
    end

    def update_order_from_intent(payment_intent_id, status:)
      record = PaymentIntent.find_by(external_id: payment_intent_id)
      return unless record

      ActiveRecord::Base.transaction do
        record.update!(status: "succeeded")
        record.order.update!(payment_status: status, status: :pending)
      end

      broadcast_order_update(record.order)
    end

    def broadcast_order_update(order)
      ActionCable.server.broadcast(
        "admin_orders",
        { event: "order_updated", order_id: order.id }
      )
    end
  end
end
