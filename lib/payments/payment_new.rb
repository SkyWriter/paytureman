module Paytureman

  VALID_OPTIONS = [
    :template_tag,
    :language,
    :url,
    :total,
    :product
  ]

  class PaymentDescription
    def initialize(description = {})
      @description = description.dup
      @description.assert_valid_keys(*VALID_OPTIONS)
    end

    def to_h
      @description.select { |_, v| v.present? }
    end
  end

  class PaymentNew < Payment

    def initialize(order_id, amount, ip, gateway = nil)
      super(order_id, amount, gateway)
      @ip = ip
    end

    def save_to_memento(memento)
      super
      memento.ip = ip
    end

    def self.new_from_memento(memento)
      new(memento.order_id, memento.amount, memento.ip, memento.gateway)
    end

    def prepare(description = PaymentDescription.new)
      session_id = payture.init(order_id, amount_in_cents, ip, description.to_h)
      if session_id
        PaymentPrepared.new(order_id, amount, session_id, gateway)
      else
        self
      end
    end

  protected

    attr_reader :ip

  end

end
