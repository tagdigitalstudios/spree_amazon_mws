require 'spree_amazon_mws/order'

module SpreeAmazonMws
  class OrderImporter
    def import_recent_orders(since=1.day.ago)
      @amazon_orders = order_fetcher.get_orders(import_recent_orders_options(since))
      @amazon_orders.each do |amazon_order|
        SpreeAmazonMws::Order.new(amazon_order).import
      end
    end

    # def update_recent_orders(since=1.day.ago)
    #   order_fetcher.get_orders(update_recent_orders_options(since))
    # end

    private
      def amazon_order_ids
        return [] unless @amazon_orders
        @amazon_orders.map{|ao| ao['AmazonOrderId'] }
      end

      def order_fetcher
        @order_fetcher ||= SpreeAmazonMws::OrderFetcher.new
      end

      def import_recent_orders_options(since)
        { created_after: since, order_status: ['Unshipped', 'PartiallyShipped', 'Shipped'], fulfillment_channel: 'MFN' }
      end

      # def update_recent_orders_options(since)
      #   { last_updated_after: since, order_status: ['Unshipped', 'PartiallyShipped', 'Shipped', 'Canceled'], fulfillment_channel: 'MFN' }
      # end

  end
end