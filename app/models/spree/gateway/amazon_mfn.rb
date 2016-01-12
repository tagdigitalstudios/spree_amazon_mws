module Spree
  class Gateway::AmazonMFN < Gateway

    def provider_class
      ActiveMerchant::Billing::AmazonMFN
    end

    def actions
      %w{capture void credit}
    end

    def supports?(source)
      source.is_a? payment_source_class
    end
  end
end
