module Spree
  class AmazonMFNCheckout < ActiveRecord::Base
    belongs_to :payment_method
    belongs_to :order

    validate :validate_checkout_matches_order

    scope :with_payment_profile, -> { all }

    def name
      "Amazon MFN Checkout"
    end

    def actions
      %w{}
    end

    def details
      @details ||= payment_method.provider.get_order token
    end

    def valid_products?
      true
    end

    def matching_shipping_address?
      true
    end

    def check_matching_billing_address
      true
    end

    def check_matching_billing_email
      true
    end

    def check_matching_product_key
      true
    end

    protected
      def validate_checkout_matches_order
        return if self.id
        check_valid_products
        check_matching_shipping_address
        check_matching_billing_address
        check_matching_billing_email
        check_matching_product_key
      end
  end
end
