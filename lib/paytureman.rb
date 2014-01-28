require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'rexml/document'
require 'rest_client'
require 'singleton'

require_relative 'payture/api'

require_relative 'payments/payment'
require_relative 'payments/payment_with_session'
require_relative 'payments/payment_new'
require_relative 'payments/payment_prepared'
require_relative 'payments/payment_blocked'
require_relative 'payments/payment_charged'
require_relative 'payments/payment_cancelled'

require_relative 'service/payment_persistence'