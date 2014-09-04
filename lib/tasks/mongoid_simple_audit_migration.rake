namespace :mongoid_simple_audit do
  
  desc "Migrates all datasets from simple audit ActiveRecord Gem into MongoDB"
  task :migrates_from_mysql_to_mongoid => :environment do
    
    # create ActiveRecord Version of Audit
    ArAudit = Class.new(ActiveRecord::Base) do
      serialize  :change_log
      self.table_name = 'audits'
    end

    total_count = ArAudit.count
    current_count = 0
    puts "starting to migrate #{total_count} records"

    ArAudit.group([:auditable_type, :auditable_id]).find_each do |auditable|
      auditable_cond = {auditable_type: auditable.auditable_type, auditable_id: auditable.auditable_id}
      audit = Mongoid::SimpleAudit::Audit.find_or_create_by( auditable_cond )

      copy_count = ArAudit.where( auditable_cond ).count
      current_count += copy_count
      puts "migrating #{copy_count} records. #{current_count-copy_count} to go"

      ArAudit.where( auditable_cond ).each do |audit_entry|        
        ds = {          
          action: audit_entry.action,
          created_at: audit_entry.created_at,
          change_log: audit_entry.change_log
        }
        if audit_entry.user_id.present?
          ds.merge!({
            user: {id: audit_entry.user_id, type: audit_entry.user_type},
            username: audit_entry.username
          })
        end
        audit.modifications.create( ds )
      end
    end
  end
end