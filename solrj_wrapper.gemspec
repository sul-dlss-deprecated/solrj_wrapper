# -*- encoding: utf-8 -*-
require File.expand_path('../lib/solrj_wrapper/version', __FILE__)
require "solrj_wrapper/version"

Gem::Specification.new do |gem|
  gem.name          = "solrj_wrapper"
  gem.version       = SolrjWrapper::VERSION
  gem.authors       = ["Naomi Dushay"]
  gem.email         = ["ndushay@stanford.edu"]
  gem.summary       = "Ruby wrapper for interacting with Solrj objects"
  gem.description   = "Ruby wrapper for interacting with Solrj objects, such as org.apache.solr.client.solrj.impl.StreamingUpdateSolrServer"
  gem.homepage      = "This gem must be run under JRuby, and also requires a directory containing SolrJ jars and solr url (see config/settings.yml)"

  gem.files         = `git ls-files`.split($\)
#  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ["lib"]
  
  # No Runtime dependencies

  # Bundler will install these gems too if you've checked out solrjwrapper source from git and run 'bundle install'
  # It will not add these as dependencies if you require solrj_wrapper for other projects
  gem.add_development_dependency "rake"
  # docs
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "yard"
  # tests
	gem.add_development_dependency 'rspec'
	gem.add_development_dependency 'simplecov'
	gem.add_development_dependency 'simplecov-rcov'
  gem.add_development_dependency "jettywrapper"

end
