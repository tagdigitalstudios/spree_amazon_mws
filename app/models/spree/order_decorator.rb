Spree::Order.class_eval do
  def amazon_order?
    amazon_order_id.present?
  end
end
