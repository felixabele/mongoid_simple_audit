# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid/simple_audit/version'

Gem::Specification.new do |spec|
  spec.name          = "mongoid_simple_audit"
  spec.version       = Mongoid::SimpleAudit::VERSION
  spec.authors       = ["Felix Abele"]
  spec.email         = ["felix.abele@googlemail.com"]
  spec.summary       = %q{Simple auditing solution for ActiveRecord models}
  spec.description   = %q{Provides a straightforward way for auditing changes on active record models, especially for composite entities. Also provides helper methods for easily rendering an audit trail in Ruby on Rails views.}
  spec.homepage      = "https://github.com/felixabele/mongoid_simple_audit.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")  
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency 'mongoid', '>= 3.0', '< 4.0.0'
  spec.add_development_dependency 'activerecord'  
  spec.add_development_dependency 'factory_girl_rails'  
  spec.add_development_dependency 'sqlite3'  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "database_cleaner"  
  
end
