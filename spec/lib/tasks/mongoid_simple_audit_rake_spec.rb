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
    person1 = create(:person)
    person2 = create(:person)
    2.times{ create :ar_audit, auditable: person1 }
    4.times{ create :ar_audit, auditable: person2 }
    @subject.invoke
    expect( Mongoid::SimpleAudit::Audit.by_auditable(ArAudit.first.auditable).where('modifications.action' => 'some-action') ).to exist
    expect( Mongoid::SimpleAudit::Audit.find_by_auditable( person1 ).modifications.count ).to be 3
    expect( Mongoid::SimpleAudit::Audit.find_by_auditable( person2 ).modifications.count ).to be 5
  end

end
