module Paytureman

  class PaymentCharged < PaymentWithSession
    def refund
      if payture.refund(order_id, (self.amount*100).round)
        PaymentRefunded.new(order_id, amount, ip, session_id)
      else
        self
      end
    end
  end

end