module Mongoid
  module SimpleAudit
    class Modification
      include Mongoid::Document
      include Mongoid::Timestamps::Created

      field :action,      type: String
      field :username,    type: String
      field :change_log,  type: Hash

      embedded_in :audit

      # Computes the differences of the change logs between two audits.
      #
      # Returns a hash containing arrays of the form 
      #   {
      #     :key_1 => [<value_in_other_change_log>, <value_in_this_audit>],
      #     :key_2 => [<value_in_other_change_log>, <value_in_this_audit>],
      #   } 
      def delta(other_change_log)
        return self.change_log if other_change_log.nil?
      
        {}.tap do |d|
          
          # first for keys present only in this audit
          (self.change_log.keys - other_change_log.change_log.keys).each do |k|
            d[k] = [nil, self.change_log[k]]
          end
      
          # .. then for keys present only in other audit
          (other_change_log.change_log.keys - self.change_log.keys).each do |k|
            d[k] = [other_change_log.change_log[k], nil]
          end
      
          # .. finally for keys present in both, but with different values
          self.change_log.keys.each do |k|
            if self.change_log[k] != other_change_log.change_log[k]
              d[k] = [other_change_log.change_log[k], self.change_log[k]]
            end
          end
      
        end

      end

      # as mongoid stores hashes keys as strings, here us a way to get the change log symbolized
      def symbolized_change_log
        sym_log = self.change_log.dup
        sym_log.symbolize_keys!
        sym_log.each{ |k,v| v.symbolize_keys! if v.is_a? Hash }
        sym_log
      end
    end
  end
end