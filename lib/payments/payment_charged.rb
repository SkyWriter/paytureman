module Paytureman

  class PaymentCharged < PaymentWithSession
    def refund
      if payture.refund(order_id, amount_in_cents)
        PaymentRefunded.new(order_id, amount, session_id, gateway)
      else
        self
      end
    end
  end

end
