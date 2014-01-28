module Paytureman

  class PaymentNew < Payment

    def prepare
      session_id = payture.init(self.order_id, (self.amount*100).round, self.ip)
      if session_id
        PaymentPrepared.new(self.order_id, self.amount, self.ip, session_id)
      else
        self
      end
    end

  end

end