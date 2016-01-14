module Spree
  class Gateway::AmazonMFN < Gateway
    preference :primary_marketplace_id, :string
    preference :merchant_id, :string
    preference :aws_access_key_id, :string
    preference :aws_secret_access_key, :string

    def provider_class
      ActiveMerchant::Billing::AmazonMFN
    end

    def payment_source_class
      Spree::AmazonMFNCheckout
    end

    def method_type
      'amazon_mfn'
    end

    def cancel(charge_ari)
      payment = Spree::Payment.valid.where(response_code: charge_ari, source_type: "#{payment_source_class}").first
      return if payment.nil?
      if payment.pending?
        payment.void_transaction!
      elsif payment.completed? and payment.can_credit?
        amount = payment.credit_allowed.to_f
        # do the credit
        provider.credit(amount, charge_ari)
        # create adjustment
        payment.order.adjustments.create(
            label: "Refund - Canceled Order",
            amount: -amount,
            order: payment.order
        )
        payment.order.update!
      end
    end

    def source_required?
      true
    end

    def supports?(source)
      source.is_a? payment_source_class
    end

    def self.version
      Gem::Specification.find_by_name('spree_amazon_mws').version.to_s
    end
  end
end
