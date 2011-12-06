# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "constantcontact/version"

Gem::Specification.new do |s|
  s.name = "constantcontact"
  s.version = ConstantContact::VERSION
  s.platform = Gem::Platform::RUBY

  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency "activeresource", "~>3.0"
  s.add_development_dependency "rspec", "~>2.7.0"
  s.add_development_dependency "rake", "=0.8.7"
  s.add_development_dependency "ratom", ">=0.6.10"
  s.add_development_dependency "fakeweb", ">=1.3.0"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features,examples}/*`.split("\n")
  s.require_paths = ["lib"]

  s.authors = ["Keith Salisbury"]
  s.email = ["keithsalisbury@gmail.com"]
  s.homepage = "http://github.com/ktec/constantcontact"
  s.summary = %q{Ruby wrapper around ConstantContact API}
  s.description = <<-EOT
Based on the original API module from DHH, http://developer.37signals.com/highrise/, this
gem is a cleaned up, tested version of the same.

Configure by adding the following:

require 'constantcontact'
ConstantContact::Base.user = 'your_username'
ConstantContact::Base.password = 'your_password'
ConstantContact::Base.api_key = 'your_api_auth_token'
EOT
end
