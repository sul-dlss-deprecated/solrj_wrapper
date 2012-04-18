require 'rspec/core/rake_task'

namespace :sj_wrap do

  desc "Run all specs, with jetty instance running"
  task :rspec_wrapped => ['sj_wrap:solrmarc:ant_dist_site', 'sj_wrap:jetty:config'] do
    test_jetty_dir = File.expand_path(File.dirname(__FILE__) + '../../../solrmarc/test/jetty')
    require 'jettywrapper'
    jetty_params = Jettywrapper.load_config.merge({
      :jetty_home => test_jetty_dir,
      :solr_home => test_jetty_dir + '/solr',
      :java_opts => "-Dsolr.data.dir=" + test_jetty_dir + "/solr/test/data",
      :jetty_port => 8985,
      :startup_wait => 25
    })
    error = Jettywrapper.wrap(jetty_params) do 
#      `sh ./spec/scripts/curl_empty_test_solr.sh`
#      `sh ./spec/scripts/curl_add_bare666_to_test.sh`
      Rake::Task['sj_wrap:rspec_plain'].invoke
    end
    raise "TEST FAILURES: #{error}" if error
  end

  RSpec::Core::RakeTask.new(:rspec_plain) do |spec|
    spec.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  end

end
