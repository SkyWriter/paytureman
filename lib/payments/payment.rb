module Paytureman
  
  class Payment
    
    attr_reader :order_id

    def initialize(order_id, amount, ip)
      @order_id, @amount, @ip = order_id, amount, ip
    end
    
    def save_to_memento(memento)
      memento.order_id, memento.amount, memento.ip = order_id, amount, ip
    end
    
    def self.new_from_memento(memento)
      new(memento.order_id, memento.amount, memento.ip)
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
        :charged => PaymentCharged
      }[payture.status(order_id)] || PaymentUnknown
      current_payment_type.new_from_payment(self)
    end

    attr_accessor :payture
    
  protected
  
    attr_accessor :amount, :ip
    attr_writer   :order_id
    
    def payture
      @payture ||= Api.instance
    end

  end

end