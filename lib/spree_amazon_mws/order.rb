module SpreeAmazonMws
  class Order
    attr_accessor :amazon_order, :spree_order
    def initialize(amazon_order)
      @amazon_order = amazon_order
    end

    def add_line_items
      return unless amazon_order && spree_order
      amazon_order_items.each do |amazon_order_item|
        variant = Spree::Variant.find_by(sku: amazon_order_item['SellerSKU'])
        spree_order.contents.add(variant, amazon_order_item['QuantityOrdered'])
      end
    end

    def add_addresses
      return unless amazon_order && spree_order
      if ship_address
        spree_order.create_bill_address(ship_address_attributes)
        spree_order.create_ship_address(ship_address_attributes)
      end
    end

    def add_payment
      return unless amazon_order && spree_order
      spree_order.payments.create(amount: amazon_order['OrderTotal']['Amount'], source: amazon_checkout, payment_method: order_fetcher.payment_method, state: 'completed')
    end

    def amazon_checkout
      Spree::AmazonMFNCheckout.new(order: spree_order, payment_method: order_fetcher.payment_method, amazon_order_id: amazon_order_id)
    end

    def amazon_order_id
      @amazon_order_id ||= amazon_order['AmazonOrderId']
    end

    def amazon_order_items
      @amazon_order_items ||= order_fetcher.get_order_items(amazon_order_id)
    end

    def finalize
      return unless amazon_order && spree_order
      if self.respond_to?(:before_finalize)
        self.before_finalize
      end
      # spree_order.select_default_shipping
      spree_order.update_column(:state, 'complete')
      spree_order.finalize!
    end

    def import
      @spree_order = Spree::Order.create(email: amazon_order['BuyerEmail'])
      add_addresses
      add_line_items
      add_payment
      finalize
      spree_order
    end

    private
      def country
        @country ||= Spree::Country.find_by(iso: ship_address['CountryCode'])
      end

      def first_name
        name.first
      end

      def last_name
        name[1..(name.size-1)].join(' ')
      end

      def name
        ship_address['Name'].split
      end

      def order_fetcher
        @order_fetcher ||= SpreeAmazonMws::OrderFetcher.new
      end

      def ship_address
        @ship_address ||= amazon_order['ShippingAddress']
      end

      def ship_address_attributes
        {
          firstname:  first_name,
          lastname:   last_name,
          address1:   ship_address['AddressLine1'],
          address2:   ship_address['AddressLine2'],
          city:       ship_address['City'],
          zipcode:    ship_address['PostalCode'],
          phone:      ship_address['Phone'],
          state_name: ship_address['StateOrRegion'],
          state:      state,
          country:    country
        }
      end

      def state
        @state ||= Spree::State.find_by(abbr: ship_address['StateOrRegion'], country_id: country.try(:id))
      end
  end
end