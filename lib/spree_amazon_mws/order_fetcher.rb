require 'peddler'

module SpreeAmazonMws
  class OrderFetcher
    attr_accessor :primary_marketplace_id, :merchant_id, :aws_access_key_id, :aws_secret_access_key, :payment_method

    def initialize
      load_payment_method
    end

    def get_order(*amazon_order_ids)
      get_order = api_client.get_order(amazon_order_ids)
      orders = get_order.parse
      orders["Orders"].to_a.map{|n, order| order }
    end

    def get_orders(opts = { created_after: 1.day.ago })
      @orders = []
      list_orders = api_client.list_orders(opts)
      begin
        orders = list_orders.parse
        @orders = @orders + orders["Orders"].to_a.map{|n, order| order }
        next_token = list_orders.next_token
        list_orders = api_client.list_orders_by_next_token(next_token) if next_token
      end while next_token
      @orders
    end

    def get_order_items(amazon_order_id)
      @order_items = []
      list_order_items = api_client.list_order_items(amazon_order_id)
      begin
        order_items = list_order_items.parse
        @order_items = @order_items + order_items["OrderItems"].to_a.map{|n, order| order }
        next_token = list_order_items.next_token
        list_order_items = api_client.list_order_items_by_next_token(next_token) if next_token
      end while next_token
      @order_items
    end

    private
      def api_client
        @api_client ||= ::MWS.orders( api_client_credentials )
      end

      def api_client_credentials
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
