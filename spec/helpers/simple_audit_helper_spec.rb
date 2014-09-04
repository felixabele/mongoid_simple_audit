require 'spec_helper'
require 'action_view'
require 'active_support'

include ActionView::Helpers::TagHelper
include ActionView::Helpers::TranslationHelper
include ActionView::Helpers::OutputSafetyHelper
include ActionView::Context


module Mongoid  

  describe SimpleAudit::Helper do
    
    include SimpleAudit::Helper

    it "should create an audit trail" do      
      person = create(:person)      
      expect( render_audits(person) ).to match person.name
    end

    it "should create mark differences between two change logs" do      
      person = create(:person)
      person.update_attribute :name, 'Franz'
      expect( render_audits(person) ).to match("<span class=\"current\">Franz</span><span class=\"previous\">Felix</span>")
    end    
  end
end