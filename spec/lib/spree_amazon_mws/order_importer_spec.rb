require 'spec_helper'

RSpec.describe SpreeAmazonMws::OrderImporter do
  subject(:order_importer) { SpreeAmazonMws::OrderImporter.new }
  let(:order_fetcher) { SpreeAmazonMws::OrderFetcher.new }
  let(:api_client) { order_fetcher.send(:api_client) }
  let(:payment_method) { FactoryGirl.create(:amazon_mfn_payment_method) }
  let(:get_order_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'get_order.xml') }
  let(:list_orders_by_next_token_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_orders_by_next_token.xml') }
  let(:list_order_items_by_next_token_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_order_items_by_next_token.xml') }
  let(:variant) { FactoryGirl.create(:variant) }

  before do
    allow(Spree::Variant).to receive(:find_by).with(sku: '10-1410-30').and_return(variant)
    allow(Spree::PaymentMethod).to receive(:find_by).with(type: 'Spree::Gateway::AmazonMFN').and_return(payment_method)
    Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrders[\&$]/ }, { body: list_orders_by_next_token_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrderItems[\&$]/ }, { body: list_order_items_by_next_token_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    allow(order_importer).to receive(:order_fetcher).and_return(order_fetcher)
  end

  describe "#import_recent_orders" do
    subject(:import_recent_orders) { order_importer.import_recent_orders }
    let(:amazon_orders) { SpreeAmazonMws::OrderFetcher.new.get_orders }
    let(:order) { SpreeAmazonMws::Order.new(amazon_orders.first) }
    before do
      allow(SpreeAmazonMws::Order).to receive(:new).with(amazon_orders.first).and_return(order)
    end
    it "expects to call order_fetcher.get_orders" do
      expect(order_fetcher).to receive(:get_orders).and_return([])
      import_recent_orders
    end
    it "is expected to create a SpreeAmazonMws::Order object" do
      expect(SpreeAmazonMws::Order).to receive(:new).with(amazon_orders.first).and_return(order)
      import_recent_orders
    end
    it "is expected to call SpreeAmazonMws::Order#import" do
      expect(order).to receive(:import)
      import_recent_orders
    end
  end

end
