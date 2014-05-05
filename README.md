# Paytureman

Payture InPay API implementation

## Installation

Add this line to your application's Gemfile:

    gem 'paytureman'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paytureman

## Usage

```ruby
require 'paytureman'

Paytureman::Configuration.setup do |config|
  config.host = "sandbox"
  config.key = "MerchantKey"
  config.password = "123"
end

# or you can use several configs
Paytureman::Configuration.setup :production do |config|
  config.host = "secure"
  config.key = "Merchant12345"
  config.password = "password"
end

order_id = SecureRandom.uuid # generate an order ID
amount = 123.15 # amount to be charged
customer_ip = "123.45.67.89" # customer's IP address

# create initial payment
payment = Paytureman::PaymentNew.new(order_id, amount, customer_ip)

# in case with several configs
payment = Paytureman::PaymentNew.new(order_id, amount, customer_ip, :production)

# prepare it
description = Paytureman::PaymentDescription.new
description.product = 'Paytureman demo payment'
description.total = amount

payment = payment.prepare(description)
# ... assert(payment.kind_of?(Paytureman::PaymentPrepared))

puts "Please, visit #{payment.url} to proceed with the payment. Then press Enter."
gets

# mark it as blocked
payment = payment.blocked
# ... assert(payment.kind_of?(Paytureman::PaymentBlocked))

# charge the customer
payment = payment.charge
# ... assert(payment.kind_of?(Paytureman::PaymentCharged))

```

## Contributing

1. Fork it ( http://github.com/SkyWriter/paytureman/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request