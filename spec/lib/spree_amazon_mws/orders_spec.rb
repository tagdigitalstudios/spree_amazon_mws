require 'spec_helper'

RSpec.describe SpreeAmazonMws::Orders do
  subject(:orders) { SpreeAmazonMws::Orders.new }
  let(:payment_method) { FactoryGirl.create(:amazon_mfn_payment_method) }
  let(:client) { orders.send(:client) }
  let(:get_order_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'get_order.xml') }
  let(:list_orders_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_orders.xml') }
  let(:list_order_items_file) { File.read ENGINE_ROOT.join('spec', 'fixtures', 'list_order_items.xml') }

  before do
    allow(Spree::PaymentMethod).to receive(:find_by).with(type: 'Spree::Gateway::AmazonMFN').and_return(payment_method)
  end

  describe "#get_order" do
    subject { super().get_order('a1b2c4d5') }
    before do
      Excon.stub({ url: client.aws_endpoint, method: :post }, { body: get_order_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    end
    it { is_expected.to be_a Peddler::XMLResponseParser }
  end

  describe "#get_orders" do
    before do
      Excon.stub({ url: client.aws_endpoint, method: :post }, { body: list_orders_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    end
    let(:time) { 1.day.ago }
    let(:get_orders) { orders.get_orders(created_after: time) }
    subject { get_orders }
    it { is_expected.to be_a Peddler::XMLResponseParser }
  end

  describe "#get_order_items" do
    before do
      Excon.stub({ url: client.aws_endpoint, method: :post }, { body: list_order_items_file, status: 200, headers: { 'Content-Type' => 'text/xml' } })
    end
    let(:time) { 1.day.ago }
    let(:get_order_items) { orders.get_order_items(created_after: time) }
    subject { get_order_items }
    it { is_expected.to be_a Peddler::XMLResponseParser }
  end
end
