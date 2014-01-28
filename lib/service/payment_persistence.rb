module Paytureman

  class PaymentPersistence
    
    include Singleton
    
    def load(memento)
      memento.type.constantize.new_from_memento(memento)
    end
    
    def save(payment, memento)
      payment.save_to_memento(memento)
      memento.type = payment.class.name
    end

  end

end