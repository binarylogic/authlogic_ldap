require "authlogic_ldap/version"
require "authlogic_ldap/acts_as_authentic"
require "authlogic_ldap/session"

ActiveRecord::Base.send(:include, AuthlogicLdap::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, AuthlogicLdap::Session)