module Paytureman

  class PaymentWithSession < Payment

    def initialize(order_id, amount, session_id, gateway = nil)
      super(order_id, amount, gateway)
      @session_id = session_id
    end

    def save_to_memento(memento)
      memento.session_id = session_id
      super(memento)
    end

    def self.new_from_memento(memento)
      new(memento.order_id, memento.amount, memento.session_id, memento.gateway)
    end

  protected

    attr_accessor :session_id

  end

end
