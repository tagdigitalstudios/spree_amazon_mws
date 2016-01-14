module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class AmazonMFN < Gateway
      self.supported_countries = %w(US)
      self.default_currency = 'USD'
      self.money_format = :cents

      def initialize(options = {})
        requires!(options, :primary_marketplace_id, :merchant_id, :aws_access_key_id, :aws_secret_access_key)
        @primary_marketplace_id = options[:primary_marketplace_id]
        @merchant_id = options[:merchant_id]
        @aws_access_key_id = options[:aws_access_key_id]
        @aws_secret_access_key = options[:aws_secret_access_key]
        super
      end

      def get_order(amazon_order_id)
        client.get_order(amazon_order_id)
      end

      private
        def client
          @client ||= MWS.orders(
            primary_marketplace_id: "foo",
            merchant_id: "bar",
            aws_access_key_id: "baz",
            aws_secret_access_key: "qux"
          )
        end
    end
  end
end
