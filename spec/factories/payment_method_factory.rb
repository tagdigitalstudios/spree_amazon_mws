FactoryGirl.define do
  factory :amazon_mfn_payment_method, class: Spree::Gateway::AmazonMFN do
    name "AmazonMFN"
    type 'Spree::Gateway::AmazonMFN'
    active true
    environment "test"
    auto_capture false
    preferred_primary_marketplace_id 'ATVPDKIKX0DER'
    preferred_merchant_id 'ABCDE12345'
    preferred_aws_access_key_id 'ABCD1234ABCD1234'
    preferred_aws_secret_access_key 'ABCD1234ABCD1234ABCD1234ABCD1234'
  end
end
