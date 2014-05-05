module Paytureman

  class Payment

    attr_accessor :gateway
    attr_reader :order_id
    attr_writer :configuration

    def initialize(order_id, amount, gateway = nil)
      @order_id = order_id
      @amount = amount
      @gateway = gateway
    end

    def save_to_memento(memento)
      memento.order_id = order_id
      memento.amount = amount
      memento.gateway = gateway
    end

    def self.new_from_memento(memento)
      new(memento.order_id, memento.amount, memento.gateway)
    end

    def self.new_from_payment(donor)
      memento = OpenStruct.new
      donor.save_to_memento(memento)
      new_from_memento(memento)
    end

    def current
      current_payment_type = {
        :new => PaymentNew,
        :prepared => PaymentPrepared,
        :authorized => PaymentBlocked,
        :voided => PaymentCancelled,
        :charged => PaymentCharged,
        :refund => PaymentRefunded
      }[payture.status(order_id)] || PaymentUnknown
      current_payment_type.new_from_payment(self)
    end

  protected

    attr_accessor :amount
    attr_writer   :order_id

    def amount_in_cents
      (amount * 100).round
    end

    def configuration
      @configuration ||= Configuration.instance
    end

    def payture
      @payture ||= configuration.api_for(gateway)
    end

  end

end
