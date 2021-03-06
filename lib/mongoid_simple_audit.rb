require 'mongoid/simple_audit/simple_audit'
require 'mongoid/simple_audit/audit'
require 'mongoid/simple_audit/modification'
require 'mongoid/simple_audit/helper'
require 'mongoid/simple_audit/engine'
require File.dirname(__FILE__) + '/mongoid/simple_audit/railtie' if defined?(Rails::Railtie)

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, Mongoid::SimpleAudit::Model
end

if defined?(Mongoid::Document)
  Mongoid::Document.send :include, Mongoid::SimpleAudit::Model
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, Mongoid::SimpleAudit::Helper
end