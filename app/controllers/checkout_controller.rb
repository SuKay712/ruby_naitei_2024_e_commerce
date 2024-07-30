class CheckoutController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    product = Product.find_by params[:id]
    @session = Stripe::Checkout::Session.create({
      payment_method_types: %w(card), # rubocop:disable Layout/FirstHashElementIndentation
      line_items: [{
        quantity: 1,
        price_data: {
          currency: "usd",
          unit_amount: (product.price * 0.042).to_i,
          product_data: {
            name: product.name
          }
        }
      }],
      mode: "payment",
      success_url: root_url,
      cancel_url: root_url
                                                })
    redirect_to @session.url, status: :see_other, allow_other_host: true
  end
end
