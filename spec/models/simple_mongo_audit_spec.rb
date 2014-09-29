# spec/models/simple_mongo_audit_spec.rb
require 'spec_helper'

module Mongoid  

  describe SimpleAudit::Audit do

    it 'should create new Audit' do      
      expect( SimpleAudit::Audit.new( auditable_type: 'SomeModel', auditable_id: 1).save ).to be true
    end

    it 'should create valid fixtures' do      
      create :address
      expect( Address.first ).not_to be_nil

      create :person
      expect( Person.first ).not_to be_nil      
      expect( Person.first.address ).not_to be_nil      
    end    

    it 'should create a new audit record with initial modification record' do 
      audit = SimpleAudit::Audit.find_or_create_by_auditable( create(:person) )
      expect( audit ).not_to be_nil
      expect( audit.modifications ).not_to be_empty
    end

    it "should set correct action" do
      address = create :address
      expect( address.audit.modifications.last.action ).to eql 'create'
    end

    it "should audit only given fields" do
      person = create :person
      person.update_attributes email: 'new@email.com', name: 'new name'
      expect( person.audit.modifications.last.change_log ).not_to have_key( 'email' )      
      expect( person.audit.modifications.last.change_log ).to have_key( 'name' )
    end

    it "should not audit if no changes where made" do
      person = create :person
      person.update_attributes name: person.name
      expect( person.audit.modifications.count ).to eql 1
    end

    it "should use proper username method" do 
      address = HomeAddress.create
      expect( User.new.short_name ).to eql address.audit.modifications.last.username

      address = Address.create
      expect( User.new.full_name ).to eql address.audit.modifications.last.username
    end

    # ----------------------------
    # --- ActiveRecord specific Tests
    # ----------------------------
    context "ActiveRecord specific Tests" do

      it "should audit associated entity changes" do
        person = create :person, address: create(:address, line_1: 'Munich'), name: 'doe1'
        create_audit = person.audit.modifications.last
        person.address = create(:address, line_1: 'Berlin')
        person.name = 'doe2'
        person.save
        update_audit = person.audit.modifications.last
        expect( update_audit.delta(create_audit) ).to eql( {"name"=>["doe1", "doe2"], "address"=>[{"line_1"=>"Munich", "zip"=>"12047"}, {"line_1"=>"Berlin", "zip"=>"12047"}]} )
      end      
    end

    # ----------------------------
    # --- Mongoid specific Tests
    # ----------------------------
    context "Mongoid specific Tests" do

      it 'should audit Mongoid models' do 
        address = Mongodoc::Address.create(line_1: 'Hans', zip: '10928')
        expect( address.audit.modifications ).not_to be_empty
      end    

      it "should audit associated entity changes" do
        person = create :mongoid_person, address: create(:mongoid_address, line_1: 'Munich'), name: 'doe1'
        create_audit = person.audit.modifications.last
        person.address = create(:mongoid_address, line_1: 'Berlin')
        person.name = 'doe2'
        person.save
        update_audit = person.audit.modifications.last
        expect( update_audit.delta(create_audit) ).to eql( {"name"=>["doe1", "doe2"], "address"=>[{"line_1"=>"Munich", "zip"=>"12047"}, {"line_1"=>"Berlin", "zip"=>"12047"}]} )
      end      
    end
  end

end  