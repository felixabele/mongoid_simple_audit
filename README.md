[![Build Status](https://travis-ci.org/felixabele/mongoid_simple_audit.svg?branch=master)](https://travis-ci.org/felixabele/mongoid_simple_audit) 

[![Coverage Status](https://img.shields.io/coveralls/felixabele/mongoid_simple_audit.svg)](https://coveralls.io/r/felixabele/mongoid_simple_audit?branch=master)

# MongoidSimpleAudit

This is modified version of the Gem simple_audit from Gabriel Tarnovan (https://github.com/gtarnovan/simple_audit) wich uses MongoDB with Mongoid instead of ActiveRecord.

# What is this Gem about?

It's a simple auditing solution for ActiveRecord models. Provides an easy way of creating audit logs for complex model associations.
Instead of storing audits for all data aggregated by the audited model, you can specify a serializable representation of the model.
    
  * a helper method is provided to easily display the audit log
  * the Audit object provides a #delta method which computes the differences between two audits

# Why ?

simple_audit is intended as a straightforward auditing solution for complex model associations. 
In a normalized data structure (which is usually the case when using SQL), a core business model will aggregate data from several associated entities.
More often than not in such cases, only the core model is of interest from an auditing point of view. 

So instead of auditing every entity separately, with simple_audit you decide for each audited model what data needs to be audited. 
This data will be serialized on every model update and the available helper methods will render a clear audit trail.

## Installation

Add this line to your application's Gemfile:

    gem 'mongoid_simple_audit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_simple_audit

Don't forget to create the MongoDB indeces

    rake db:mongoid:create_indexes

## Usage

  class Booking < ActiveRecord::Base
    simple_audit do |record|
      # data to be audited
      {
          :price => record.price,
          :period => record.period, 
          ...
      }
    end
  end
  
  # in your view
  <%= render_audits(@booking) %>

Audit ActiveRecord models. Somewhere in your (backend) views show the audit logs.
    
    # in your model
    # app/models/booking.rb
    
    class Booking < ActiveRecord::Base
        simple_audit
        ...
    end
    
    # in your view
    # app/views/bookings/booking.html.erb
    
    ...
    <%= render_audits(@booking) %>
    ...     

## Sample styling
      .audits {
        clear: both;
      }
      .audit {
        -moz-border-radius:8px;
        -webkit-border-radius: 8px;
        background-color: #dfdfdf;
        padding: 6px;
        margin-bottom: 8px;
        font-size: 12px;
      }
      .audit .action, .audit .user, .audit .timestamp{
        float: left;
        margin-right: 6px;
      }
      .audit .changes {
        clear: both;
        white-space: pre;
      }

      .audit .current {
        margin-left: 6px;
      }
      .audit .previous {
        margin-left: 6px;
        text-decoration: line-through;
      }  

# Assumptions and limitations

  * Your user model is called User (or Cms::User) and the current user User.current
    See [sentient_user](http://github.com/bokmann/sentient_user) for more information.

    
## Customize auditing

By default after each save, all model's attributes and `belongs_to` associations (their `id` and `to_s` on these) are saved in the audits table.
You can customize the data which is saved by supplying a block which will return all relevant data for the audited model.

    # app/models/booking.rb
    
    class Booking < ActiveRecord::Base
        simple_audit do |record|
          {
            :state  => record.state, 
            :price  => record.price.format,
            :period => record.period.to_s,
            :housing_units => record.housing_units.collect(&:name).join('; '),
            ...
            }
        end
        ...
    end
    
You can also customize the attribute of the User model which will be stored in the audit.

    # default is :name
    simple_audit :username_method => :email

As a default it will audit all save and update calls even though no changes where made, unless you specify :audit_changes_only => true

  simple_audit :audit_changes_only => true
    
## Rendering audit trail

A helper method for displaying a list of audits is provided. It will render a decorated list of the provided audits;
only the differences between revisions will be shown, thus making the audit information easily readable.

## Why I consider the MongoDB Version more suitable to the original with ActiveRecord
1. Changed attributes are natively searchable by the database
2. Better perfomance
3. High scalability

Negative aspect though, its not working nicely hand in hand with not MongoDB backends

## Contributing

1. Fork it ( https://github.com/felixabele/mongoid_simple_audit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
