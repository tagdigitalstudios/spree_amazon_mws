class AddAmazonOrderIdToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :amazon_order_id, :string, index: true
  end
end
