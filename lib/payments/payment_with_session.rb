module Paytureman
  
  class PaymentWithSession < Payment
    
    def initialize(order_id, amount, ip, session_id)
      @session_id = session_id
      super(order_id, amount, ip)
    end

    def save_to_memento(memento)
      memento.session_id = session_id
      super(memento)
    end
    
    def self.new_from_memento(memento)
      new(memento.order_id, memento.amount, memento.ip, memento.session_id)
    end    
    
  protected
  
    attr_accessor :session_id
    
  end

end