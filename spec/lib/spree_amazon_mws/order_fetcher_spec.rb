require 'spec_helper'

RSpec.describe SpreeAmazonMws::OrderFetcher do
  subject(:order_fetcher) { SpreeAmazonMws::OrderFetcher.new }
  let(:payment_method) { FactoryGirl.create(:amazon_mfn_payment_method) }
  let(:api_client) { order_fetcher.send(:api_client) }
  let(:get_order_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'get_order.xml') }
  let(:list_orders_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_orders.xml') }
  let(:list_orders_single_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_orders_single.xml') }
  let(:list_orders_by_next_token_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_orders_by_next_token.xml') }
  let(:list_order_items_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_order_items.xml') }
  let(:list_order_items_by_next_token_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_order_items_by_next_token.xml') }

  before do
    allow(Spree::PaymentMethod).to receive(:find_by).with(type: 'Spree::Gateway::AmazonMFN').and_return(payment_method)
  end

  describe "#get_order" do
    let(:get_order) { order_fetcher.get_order('a1b2c4d5') }
    subject { get_order }
    before do
      Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=GetOrder[\&$]/ }, { body: get_order_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    end
    it { is_expected.to be_an Array }
    it "is expected to have a size of 0" do
      expect(get_order.size).to eq 0
    end
  end

  describe "#get_orders" do
    before do
      Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrders[\&$]/ }, { body: list_orders_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
      Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrdersByNextToken[\&$]/ }, { body: list_orders_by_next_token_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    end
    let(:time) { 1.day.ago }
    let(:get_orders) { order_fetcher.get_orders(created_after: time) }
    subject { get_orders }
    it { is_expected.to be_an Array }
    it "is expected to have a size of 3", focus: true do
      expect(get_orders.size).to eq 3
    end
    it "should have an AmazonOrderId for each order" do
      expect(get_orders.all?{|o| o['AmazonOrderId'].present? }).to eql true
    end
    context "with a single order" do
      before do
        Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrders[\&$]/ }, { body: list_orders_single_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
      end
      it { is_expected.to be_an Array }
      it "is expected to have a size of 1", focus: true do
        expect(get_orders.size).to eq 1
      end
      it "should have an AmazonOrderId for each order" do
        expect(get_orders.all?{|o| o['AmazonOrderId'].present? }).to eql true
      end
    end
    context "with multiple orders" do
      before do
        Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrders[\&$]/ }, { body: list_orders_by_next_token_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
      end
      it { is_expected.to be_an Array }
      it "is expected to have a size of 2", focus: true do
        expect(get_orders.size).to eq 2
      end
      it "should have an AmazonOrderId for each order" do
        expect(get_orders.all?{|o| o['AmazonOrderId'].present? }).to eql true
      end
    end
  end

  describe "#get_order_items" do
    before do
      Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrderItems[\&$]/ }, { body: list_order_items_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
      Excon.stub({ url: api_client.aws_endpoint, method: :post, body: /Action=ListOrderItemsByNextToken[\&$]/ }, { body: list_order_items_by_next_token_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    end
    let(:time) { 1.day.ago }
    let(:get_order_items) { order_fetcher.get_order_items(created_after: time) }
    subject { get_order_items }
    it { is_expected.to be_an Array }
    it "is expected to have a size of 3" do
      expect(get_order_items.size).to eq 3
    end
  end
end
