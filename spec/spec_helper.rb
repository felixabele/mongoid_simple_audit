require 'coveralls'
Coveralls.wear!
$:.unshift(File.join(File.dirname(__FILE__),'..','lib'))

require 'mongoid'
require 'rubygems'
require 'active_record'
require 'factory_girl_rails'
require 'bundler'
require 'mongoid_simple_audit'

def database_id
    ENV['CI'] ? "mongoid_simple_audit_#{Process.pid}" : 'mongoid_simple_audit_test'
end

Mongoid.configure do |config|
  config.connect_to database_id
end


RSpec.configure do |c|

  c.color = true
  c.tty = true
  c.formatter = :documentation  
  c.include FactoryGirl::Syntax::Methods
  
  c.before(:each) do |example|
    unless example.metadata[:keep_datasets]
      Mongoid.purge!
      Mongoid::IdentityMap.clear if defined?(Mongoid::IdentityMap)
    end
  end

  c.after(:suite) do
    Mongoid::Threaded.sessions[:default].drop if ENV['CI']
  end
end

ActiveRecord::Base.establish_connection({
  :adapter  => 'sqlite3',
  :database => ':memory:'
})

ActiveRecord::Migration.suppress_messages {
  ActiveRecord::Schema.define do
    suppress_messages do
      create_table "people", :force => true do |t|
        t.column "name",  :text
        t.column "email", :text
      end
      create_table "addresses", :force => true do |t|
        t.column "line_1", :text
        t.column "zip", :text
        t.column "type", :text
        t.references :person
      end
      create_table "users", :force => true do |t|
        t.column "name", :text
      end

      # in order to test migration from ActiveRecord
      create_table "audits", :force => true do |t|
        t.belongs_to :auditable,  :polymorphic => true
        t.belongs_to :user,       :polymorphic => true
        t.string :username
        t.string :action
        t.text   :change_log
        t.timestamps
      end      
    end
  end
}

class Address < ActiveRecord::Base
  belongs_to :person
  simple_audit( username_method: :full_name )
end

class Person < ActiveRecord::Base
  has_one :address
  simple_audit( audit_changes_only: true ) do |record|
    {
      name: record.name,
      address: { line_1: record.address.line_1, zip: record.address.zip }
    }
  end
end

module Mongodoc
  class Address  
    include Mongoid::Document
    field :line_1
    field :zip
    field :type

    embeds_one :person, class_name: 'Mongodoc::Person'
    simple_audit
  end

  class Person
    include Mongoid::Document
    field :name
    field :email
    embedded_in :address, class_name: 'Mongodoc::Address'
    simple_audit( audit_changes_only: true ) do |record|
      {
        name: record.name,
        address: { line_1: record.address.line_1, zip: record.address.zip }
      }
    end    
  end
end

class HomeAddress < Address
  simple_audit :username_method => :short_name 
end

class ArAudit < ActiveRecord::Base
  belongs_to :auditable,  :polymorphic => true
  belongs_to :user,       :polymorphic => true    
  serialize  :change_log
  self.table_name = "audits"
end

class User < ActiveRecord::Base
  def self.current; User.first ; end
  
  def name
    "name"
  end
  
  def full_name
    "full_name"
  end
  
  def short_name
    "short_name"
  end
end

require 'factories'

User.create(:name => "some user")