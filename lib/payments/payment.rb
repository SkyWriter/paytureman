module Paytureman
  
  class Payment
    
    def initialize(order_id, amount, ip)
      @order_id, @amount, @ip = order_id, amount, ip
    end
    
    def save_to_memento(memento)
      memento.order_id, memento.amount, memento.ip = order_id, amount, ip
    end
    
    def self.new_from_memento(memento)
      new(memento.order_id, memento.amount, memento.ip)
    end
    
    attr_accessor :payture
    
  protected
  
    attr_accessor :order_id, :amount, :ip
    
    def payture
      @payture ||= Api.instance
    end

  end

end