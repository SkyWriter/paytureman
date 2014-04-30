module Paytureman

  class Payment

    attr_reader :order_id

    def initialize(gateway, order_id, amount, ip)
      @gateway, @order_id, @amount, @ip = gateway, order_id, amount, ip
    end

    def save_to_memento(memento)
      memento.gateway, memento.order_id, memento.amount, memento.ip = gateway, order_id, amount, ip
    end

    def self.new_from_memento(memento)
      new(memento.gateway, memento.order_id, memento.amount, memento.ip)
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

    attr_writer :gateway_configurator
    attr_accessor :gateway

  protected

    attr_accessor :amount, :ip, :payture
    attr_writer   :order_id

    def gateway_configurator
      @gateway_configurator ||= GatewayConfigurator.instance
    end

    def payture
      gateway_configurator.create_api_by_name(gateway)
    end

  end

end
