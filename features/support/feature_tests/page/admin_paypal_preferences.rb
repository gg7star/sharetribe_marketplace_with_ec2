module FeatureTests
  module Page
    module AdminPaypalPreferences
      extend Capybara::DSL

      module_function

      def payment_settings
        find(".payment-settings")
      end

      def connect_paypal_account
        payment_settings.click_button("Connect your PayPal account")
      end

      def set_payment_preferences(min_price:, commission:, min_commission:)
        payment_settings.fill_in("paypal_preferences_form[minimum_listing_price]", with: min_price)
        payment_settings.fill_in("paypal_preferences_form[commission_from_seller]", with: commission)
        payment_settings.fill_in("paypal_preferences_form[minimum_transaction_fee]", with: min_commission)
      end

      def save_settings
        payment_settings.click_button("Save settings")
      end
    end
  end
end
