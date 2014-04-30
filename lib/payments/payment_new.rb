module Paytureman

  class PaymentDescription < Struct.new(:product, :total, :template_tag, :language)

    def to_h
      super.select { |_, v| v.present? }
    end

  end

  class PaymentNew < Payment

    def prepare(description = PaymentDescription.new)
      session_id = payture.init(self.order_id, (self.amount*100).round, self.ip, description.to_h)
      if session_id
        PaymentPrepared.new(self.gateway, self.order_id, self.amount, self.ip, session_id)
      else
        self
      end
    end

  end

end
