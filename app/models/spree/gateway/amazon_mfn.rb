module Spree
  class Gateway::AmazonMFN < Gateway

    def provider_class
      ActiveMerchant::Billing::AmazonMFN
    end

    def actions
      %w{capture void credit}
    end
  end
end
