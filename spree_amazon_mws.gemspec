# encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)
require "spree_amazon_mws/version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_amazon_mws'
  s.version     = SpreeAmazonMws::VERSION
  s.summary     = 'Integrate Amazon MWS into Spree'
  s.description = 'Specifically, for merchant fulfilled orders, we need a way to import orders into spree, track them and notify Amazon when they are shipped.'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Tim Glen'
  s.email     = 'tim@tagstudios.io'
  s.homepage  = 'http://www.tagstudios.io'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.4.0'
  s.add_dependency 'peddler', '~> 1.2.0'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'money'
  s.add_development_dependency 'rspec-rails',  '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 4.0.3'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
  s.add_development_dependency 'sqlite3'
end
