# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "paytureman"
  spec.version       = "0.2.0"
  spec.authors       = ["Ivan Kasatenko"]
  spec.email         = ["ivan@uniqsystems.ru"]
  spec.summary       = %q{Payture API implementation}
  spec.description   = %q{Payture InPay API implementation}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest_client", "~> 1.7"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "bond"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
end
