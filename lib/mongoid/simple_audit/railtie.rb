module Mongoid
  module SimpleAudit
    class Railtie < Rails::Railtie
      railtie_name :mongoid_simple_audit

      rake_tasks do
        require 'mongoid/simple_audit/tasks'
      end
    end
  end
end