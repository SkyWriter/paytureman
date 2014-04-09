module Paytureman

  class PaymentPrepared < PaymentWithSession

    def url
      "https://sandbox.payture.com/apim/Pay?SessionId=#{session_id}"
    end

    def block
      PaymentBlocked.new(order_id, amount, ip, session_id)
    end

  end

end