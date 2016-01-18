require 'spec_helper'

RSpec.describe SpreeAmazonMws::Order do
  subject(:order) { SpreeAmazonMws::Order.new(amazon_order) }
  let(:amazon_order) do
    Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrders[\&$]/ }, { body: list_orders_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    order_fetcher.get_orders.first
  end
  let(:amazon_order_items) do
    Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrderItems[\&$]/ }, { body: list_order_items_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    order_fetcher.get_order_items(amazon_order_id)
  end
  let(:amazon_order_id) { amazon_order['AmazonOrderId'] }
  let(:api_client) { order_fetcher.send(:api_client) }
  let(:order_fetcher) { SpreeAmazonMws::OrderFetcher.new }
  let(:list_orders_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_orders_by_next_token.xml') }
  let(:list_order_items_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_order_items_by_next_token.xml') }
  let(:order_contents) { Spree::OrderContents.new(spree_order) }
  let(:payment_method) { FactoryGirl.create(:amazon_mfn_payment_method) }
  let!(:shipping_method) { FactoryGirl.create(:free_shipping_method) }
  let(:spree_order) { Spree::Order.create(amazon_order_id: amazon_order_id, email: amazon_order['BuyerEmail']) }
  let(:variant) { FactoryGirl.create(:variant) }

  before do
    allow(Spree::PaymentMethod).to receive(:find_by).with(type: 'Spree::Gateway::AmazonMFN').and_return(payment_method)
    allow(order).to receive(:amazon_order).and_return(amazon_order)
    allow(order).to receive(:amazon_order_items).and_return(amazon_order_items)
    allow(spree_order).to receive(:contents).and_return(order_contents)
  end

  describe "#import" do
    subject(:import) { order.import }
    before do
      allow(Spree::Order).to receive(:find_or_create_by).with(amazon_order_id: amazon_order_id).and_return(spree_order)
      allow(Spree::Order).to receive(:find_by).with(sku: '10-1410-30').and_return(variant)
      allow(Spree::Variant).to receive(:find_by).with(sku: amazon_order_items.first['SellerSKU']).and_return(variant)
    end
    it "is expected to start a new spree order with the seller information" do
      expect(Spree::Order).to receive(:find_or_create_by).with(amazon_order_id: amazon_order_id).and_return(spree_order) # see fixtures/list_orders.xml
      import
    end
    it "expects the spree order to create a billing and shipping address" do
      import
      expect(spree_order.ship_address).to be_persisted
      expect(spree_order.bill_address).to be_persisted
    end
    it "is expected to match the spree order SellerSKU with a SKU from the store" do
      expect(Spree::Variant).to receive(:find_by).with(sku: amazon_order_items.first['SellerSKU']).and_return(variant) # see fixtures/list_order_items.xml
      import
    end
    it "is expected to add the variant to the order_contents" do
      expect(order_contents).to receive(:add).with(variant, amazon_order_items.first['QuantityOrdered']).twice
      import
    end
    it "is expected to add a line_item to the spree_order" do
      expect{import}.to change{spree_order.line_items.count}.by(1)
    end
    it "is expected to add a payment to the spree_order" do
      expect{import}.to change{spree_order.payments.count}.by(1)
    end
    it "should finalize the order" do
      expect(spree_order).to receive(:update_column).with(:state, 'complete')
      expect(spree_order).to receive(:finalize!)
      import
    end
  end

end
