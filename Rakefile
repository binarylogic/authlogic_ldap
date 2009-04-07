ENV['RDOCOPT'] = "-S -f html -T hanna"

require "rubygems"
require "hoe"
require File.dirname(__FILE__) << "/lib/authlogic_ldap/version"

Hoe.new("Authlogic LDAP", AuthlogicLdap::Version::STRING) do |p|
  p.name = "authlogic-ldap"
  p.rubyforge_name = "authlogic-ldap"
  p.author = "Ben Johnson of Binary Logic"
  p.email  = 'bjohnson@binarylogic.com'
  p.summary = "Extension of the Authlogic library to add LDAP support."
  p.description = "Extension of the Authlogic library to add LDAP support."
  p.url = "http://github.com/binarylogic/authlogic_ldap"
  p.history_file = "CHANGELOG.rdoc"
  p.readme_file = "README.rdoc"
  p.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc"]
  p.remote_rdoc_dir = ''
  p.test_globs = ["test/*/test_*.rb", "test/*_test.rb", "test/*/*_test.rb"]
  p.extra_deps = %w(authlogic ruby-net-ldap)
end