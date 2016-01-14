FactoryGirl.define do
  factory :amazon_mfn_payment, class: Spree::Payment do
    amount 45.75
    association(:payment_method, factory: :amazon_mfn_payment_method)
    association(:source, factory: :amazon_mfn_checkout)
    order
    state 'checkout'
    response_code '12345'
  end
end
