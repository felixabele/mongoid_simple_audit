module Mongoid
  module SimpleAudit
    class Audit
      include Mongoid::Document

      field :auditable_type,  type: String
      field :auditable_id,    type: String

      index({ auditable_id: 1, auditable_type: 1 })

      embeds_many :modifications

      scope :by_auditable, (lambda do |auditable|
        where( auditable_type: auditable.class.name, auditable_id: auditable.id )
      end)      

      def self.find_or_create_by_auditable auditable
        self.find_or_create_by( auditable_type: auditable.class.name, auditable_id: auditable.id )
      end

      def self.find_by_auditable auditable
        self.by_auditable( auditable ).first
      end

    end
  end
end