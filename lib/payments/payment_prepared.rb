module Paytureman

  class PaymentPrepared < PaymentWithSession

    def url
      payture.pay_url(session_id)
    end

    def block
      PaymentBlocked.new(order_id, amount, session_id, gateway)
    end

  end

end
