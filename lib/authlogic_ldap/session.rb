module AuthlogicLdap
  module Session
    # Add a simple openid_identifier attribute and some validations for the field.
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods
      end
    end
    
    module Config
      # The host of your LDAP server.
      #
      # * <tt>Default:</tt> nil
      # * <tt>Accepts:</tt> String
      def ldap_host(value = nil)
        config(:ldap_host, value)
      end
      alias_method :ldap_host=, :ldap_host
      
      # The port of your LDAP server.
      #
      # * <tt>Default:</tt> 389
      # * <tt>Accepts:</tt> Fixnum, integer
      def ldap_port(value = nil)
        config(:ldap_port, value, 389)
      end
      alias_method :ldap_port=, :ldap_port
      
      # Once LDAP authentication has succeeded we need to find the user in the database. By default this just calls the
      # find_by_ldap_login method provided by ActiveRecord. If you have a more advanced set up and need to find users
      # differently specify your own method and define your logic in there.
      #
      # For example, if you allow users to store multiple ldap logins with their account, you might do something like:
      #
      #   class User < ActiveRecord::Base
      #     def self.find_by_ldap_login(login)
      #       first(:conditions => ["#{LdapLogin.table_name}.login = ?", login], :join => :ldap_logins)
      #     end
      #   end
      #
      # * <tt>Default:</tt> :find_by_ldap_login
      # * <tt>Accepts:</tt> Symbol
      def find_by_ldap_login_method(value = nil)
        config(:find_by_ldap_login_method, value, :find_by_ldap_login)
      end
      alias_method :find_by_ldap_login_method=, :find_by_ldap_login_method
    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
          attr_accessor :ldap_login
          attr_accessor :ldap_password
          validate :validate_by_ldap, :if => :authenticating_with_ldap?
        end
      end
      
      # Hooks into credentials to print out meaningful credentials for LDAP authentication.
      def credentials
        if authenticating_with_ldap?
          details = {}
          details[:ldap_login] = send(login_field)
          details[:ldap_password] = "<protected>"
          details
        else
          super
        end
      end
      
      # Hooks into credentials so that you can pass an :ldap_login and :ldap_password key.
      def credentials=(value)
        super
        values = value.is_a?(Array) ? value : [value]
        hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
        if !hash.nil?
          self.ldap_login = hash[:ldap_login] if hash.key?(:ldap_login)
          self.ldap_password = hash[:ldap_password] if hash.key?(:ldap_password)
        end
      end
      
      private
        def authenticating_with_ldap?
          !ldap_host.blank? && (!ldap_login.blank? || !ldap_password.blank?)
        end
        
        def validate_by_ldap
          errors.add(:ldap_login, I18n.t('error_messages.ldap_login_blank', :default => "can not be blank")) if ldap_login.blank?
          errors.add(:ldap_password, I18n.t('error_messages.ldap_password_blank', :default => "can not be blank")) if ldap_password.blank?
          return if errors.count > 0
          
          ldap = Net::LDAP.new
          ldap.host = ldap_host
          ldap.port = ldap_port
          ldap.auth ldap_login, ldap_password
          if ldap.bind
            self.attempted_record = search_for_record(find_by_ldap_login_method, ldap_login)
            errors.add(:ldap_login, I18n.t('error_messages.ldap_login_not_found', :default => "does not exist")) if attempted_record.blank?
          else
            errors.add_to_base(ldap.get_operation_result.message)
          end
        end
        
        def ldap_host
          self.class.ldap_host
        end
        
        def ldap_port
          self.class.ldap_port
        end
    end
  end
end