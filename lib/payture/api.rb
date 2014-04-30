module Paytureman
  class Api
    attr_accessor :rest_client

    def initialize(url, key)
      @url, @key = url, key
    end

    def init(order_id, amount, ip, description = {})

      data = { SessionType: :Block, OrderId: order_id, Amount: amount, IP: ip }
      data.merge!(description)

      init_params = {
          'Data' => URI.escape(data.map { |a| a.join('=').camelize }.join(';'))
      }

      response = make_request(:init, init_params)
      response[:success] && response[:session_id]
    end

    def charge(order_id, session_id)
      response = make_request(:charge, order_id: order_id, password: '123')
      response[:success]
    end

    def refund(order_id, amount)
      response = make_request(:refund, order_id: order_id, amount: amount, password: '123')
      response[:success]
    end

    def unblock(order_id, amount)
      response = make_request(:unblock, order_id: order_id, amount: amount, password: '123')
      response[:success]
    end

    def status(order_id)
      response = make_request(:pay_status, order_id: order_id)
      return :prepared if !response[:success] && response[:err_code] == :none
      response[:success] && response[:state]
    end

  protected

    def rest_client
      @rest_client ||= RestClient
    end

    def make_request(method, params)
      params = Hash[
          params.merge(key: @key).
              map { |k, v| [ k.to_s.camelize, v ] }
      ]
      response = rest_client.post "#{@url}/#{method.to_s.camelize}", params
      puts response.body
      return nil if response.body.empty?
      doc = REXML::Document.new(response.body)
      result = Hash[doc.elements.first.attributes.map { |a| [ a.first.underscore.to_sym, a.last ] }]
      if result[:success]
        result[:success] = result[:success].downcase == "true"
      end
      if result[:state]
        result[:state] = result[:state].underscore.to_sym
      end
      if result[:amount]
        result[:amount] = result[:amount].to_i
      end
      if result[:err_code]
        result[:err_code] = result[:err_code].downcase.to_sym
      end
      return result
    end

  end
end

