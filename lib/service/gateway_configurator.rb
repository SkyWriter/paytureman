class GatewayConfigurator

  include Singleton

  def initialize
    @configurations = { }
  end

  def create_api_by_name(name)
    raise GatewayNotFoundException.new(name) unless config = @configurations[name.to_sym]
    Paytureman::Api.new(config.url, config.key)
  end

  def configure(name)
    config = GatewayConfiguration.new
    yield config
    @configurations[name.to_sym] = config
  end

  private

  class GatewayConfiguration < Struct.new(:key, :url)
  end

end

class GatewayNotFoundException < Exception

  def initialize(name)
    super("Gateway #{name} has not been defined in the configuration")
  end

end

