# rake mongoid_simple_audit:migrates_from_mysql_to_mongoid

namespace :mongoid_simple_audit do
  
  desc "Migrates all datasets from simple audit ActiveRecord Gem into MongoDB"
  task :migrates_from_mysql_to_mongoid => :environment do

    # create ActiveRecord Version of Audit
    ArAudit = Class.new(ActiveRecord::Base) do
      belongs_to :auditable,  :polymorphic => true
      belongs_to :user,       :polymorphic => true          
      serialize  :change_log
      self.table_name = 'audits'
    end

    total_count = ArAudit.count
    new_audit = nil
    current_count = 0
    batch_size = 1000
    offset = 0
    puts "starting to migrate #{total_count} records."

    loop do
      break if offset > total_count

      ArAudit.offset( offset ).limit( batch_size ).order( [:auditable_type, :auditable_id] ).each do |audit|

        if new_audit.nil? || new_audit.auditable_id != audit.auditable_id || new_audit.auditable_type != audit.auditable_type
          new_audit = Mongoid::SimpleAudit::Audit.find_or_create_by( {auditable_type: audit.auditable_type, auditable_id: audit.auditable_id} )
        end

        current_count += 1
        if (current_count % batch_size == 0) || (total_count < batch_size)
          puts "migrated #{current_count}. #{total_count-current_count} remaining"
        end

        begin
          ds = {          
            action: audit.action,
            created_at: audit.created_at,
            change_log: audit.change_log
          }
          if audit.user_id.present?
            ds.merge!({
              user: {id: audit.user_id, type: audit.user_type},
              username: audit.username
            })
          end
          new_audit.modifications.create( ds )
        rescue Exception => e 
          puts "could not copy audit with ID: #{audit.id} because: #{e.message}"
        end
      end # <- END: Find Audits
      offset += batch_size
    end # <- END: batch-loop
  end
end