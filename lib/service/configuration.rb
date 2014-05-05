module Paytureman
  class Configuration
    include Singleton

    class << self
      def setup(namespace = nil)
        settings = Settings.new
        yield settings
        instance.add_settings(namespace, settings)
      end
    end

    attr_accessor :configurations

    def initialize
      @configurations = {}
      add_settings(nil, Settings.new)
    end

    def add_settings(namespace, settings)
      configurations[gateway_name(namespace)] = settings
    end
  
    def settings(namespace)
      configurations[gateway_name(namespace)]
    end

    def api_for(namespace)
      config = settings(namespace) or raise GatewayNotFoundException.new(namespace)
      Paytureman::Api.new(config.host, config.key, config.password)
    end

  private

    def gateway_name(key)
      key.to_s.to_sym
    end
  end

  class Settings
    attr_accessor :host, :key, :password

    def initialize
      @host = 'sandbox'
      @key = 'MerchantRutravel'
      @password = '123'
    end
  end

  class GatewayNotFoundException < Exception
    def initialize(name)
      super("Gateway #{name} has not been defined in the configuration")
    end
  end

end