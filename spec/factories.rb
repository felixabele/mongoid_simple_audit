FactoryGirl.define do
  
  factory :address do
    line_1  "John"
    zip     "12047"
  end

  factory :person do
    name  "Felix"
    email "felix.abele@gmail.com"
    address
  end  

  factory :mongoid_address, class: "Mongodoc::Address" do
    line_1  "John"
    zip     "12047"
  end  

  factory :mongoid_person, class: "Mongodoc::Person" do
    name  "Felix"
    email "felix.abele@gmail.com"
    address {FactoryGirl.build( :mongoid_address )}
  end  

  factory :user do
    name  "Some user"
  end  

  factory :ar_audit, class: ArAudit do
    association :auditable, :factory => :person
    association :user, :factory => :user
    action "some-action"
    change_log( {'name' => 'Joe'} )
  end    

end