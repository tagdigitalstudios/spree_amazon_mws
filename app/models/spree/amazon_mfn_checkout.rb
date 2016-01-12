module Spree
  class AmazonMFNCheckout < ActiveRecord::Base
    belongs_to :payment_method
    belongs_to :order

    def name
      "Amazon MFN Checkout"
    end
  end
