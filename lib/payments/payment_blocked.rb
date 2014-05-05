module Paytureman

  class PaymentBlocked < PaymentWithSession

    def unblock
      if payture.unblock(order_id, amount_in_cents)
        PaymentCancelled.new(order_id, amount, session_id, gateway)
      else
        self
      end
    end

    def charge
      if payture.charge(order_id)
        PaymentCharged.new(order_id, amount, session_id, gateway)
      else
        self
      end
    end

  end

end