require 'peddler'

module SpreeAmazonMws
  class Orders
    attr_accessor :primary_marketplace_id, :merchant_id, :aws_access_key_id, :aws_secret_access_key

    def initialize
      load_payment_method
    end

    def get_order(*amazon_order_ids)
      client.get_order(amazon_order_ids)
    end

    def get_orders(opts = { created_after: 1.day.ago })
      client.list_orders(opts)
    end

    def get_order_items(*amazon_order_ids)
      client.list_order_items(*amazon_order_ids)
    end

    private
      def client
        @client ||= ::MWS.orders( client_credentials )
      end

      def client_credentials
        {
          primary_marketplace_id: @primary_marketplace_id,
          merchant_id: @merchant_id,
          aws_access_key_id: @aws_access_key_id,
          aws_secret_access_key: @aws_secret_access_key
        }
      end

      def load_payment_method
        @payment_method ||= Spree::PaymentMethod.find_by(type: 'Spree::Gateway::AmazonMFN')
        if @payment_method
          @primary_marketplace_id = @payment_method.preferred_primary_marketplace_id
          @merchant_id = @payment_method.preferred_merchant_id
          @aws_access_key_id = @payment_method.preferred_aws_access_key_id
          @aws_secret_access_key = @payment_method.preferred_aws_secret_access_key
        end
        @payment_method
      end
  end
end
