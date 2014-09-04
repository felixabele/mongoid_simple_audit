# spec/lib/tasks/mongoid_simple_audit_rake_spec.rb
require 'spec_helper'
require 'rake'

describe "mongoid_simple_audit:migrates_from_mysql_to_mongoid" do

  before(:each) do
    task_name = 'mongoid_simple_audit:migrates_from_mysql_to_mongoid'
    task_path = "../lib/tasks/mongoid_simple_audit_migration"
    rake = Rake::Application.new
    Rake.application = rake
    Rake.application.rake_require( task_path )
    Rake::Task.define_task(:environment)
    @subject = rake[task_name]
  end

  it "task should copy datasets from ActiveRecord to MongoDB" do        
    audit = create :ar_audit
    @subject.invoke
    expect( Mongoid::SimpleAudit::Audit.by_auditable(audit.auditable).where('modifications.action' => 'some-action') ).to exist
  end

end
