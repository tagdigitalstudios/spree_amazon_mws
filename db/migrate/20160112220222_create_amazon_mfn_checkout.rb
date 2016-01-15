class CreateAmazonMfnCheckout < ActiveRecord::Migration
  def change
    create_table :spree_amazon_mfn_checkouts do |t|
      t.string     :amazon_order_id
      t.references :order
      t.references :payment_method
      t.timestamps
    end
  end
end
