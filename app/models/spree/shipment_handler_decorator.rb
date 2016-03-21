Spree::ShipmentHandler.class_eval do
  private
    def send_shipped_email
      ShipmentMailer.shipped_email(@shipment.id).deliver if !@shipment.order.amazon_order?
    end
end
