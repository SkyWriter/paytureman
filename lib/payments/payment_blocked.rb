module Paytureman

  class PaymentBlocked < PaymentWithSession

    def unblock
      if payture.unblock(order_id, (self.amount*100).round)
        PaymentCancelled.new(order_id, amount, ip, session_id)
      else
        self
      end
    end

    def charge
      if payture.charge(order_id, session_id)
        PaymentCharged.new(order_id, amount, ip, session_id)
      else
        self
      end
    end

  end

end