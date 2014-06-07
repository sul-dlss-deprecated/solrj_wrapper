require 'jettywrapper'

desc "run continuous integration suite (tests, coverage, docs)" 
task :ci do 
  Rake::Task["sj_wrap:rspec_wrapped"].invoke
  Rake::Task["sj_wrap:doc"].invoke
end

desc 'clone solrmarc-sw from sul-dlss github'
task :clone_solrmarc do
  `git clone https://github.com/sul-dlss/solrmarc-sw.git` unless File.directory? 'solrmarc-sw'
end

desc "set up Solr for testing in jetty"
task :setup_jetty => :clone_solrmarc do
  Dir.chdir('solrmarc-sw') do 
    `git pull`
    `ant ext_setup`
  end
end
task :setup_test_solr => :setup_jetty

desc "start jetty for running tests"
task :run_jetty do
  `rm -rf solrmarc-sw/test/jetty/solr/data/index`
  jetty_dir = File.expand_path(File.dirname(__FILE__) + '../../../solrmarc-sw/test/jetty')
  jetty_params = Jettywrapper.load_config.merge({:jetty_home => jetty_dir,
                                                :solr_home => jetty_dir + '/solr',
                                                :java_opts => "-Dsolr.data.dir=" + jetty_dir + "/solr/data",
                                                :startup_wait => 45,
                                                :jetty_port => 8984
                                                })
  error = Jettywrapper.start(jetty_params) 
end
task :jetty_start => :run_jetty
task :start_jetty => :run_jetty

desc  "stop jetty used for testing"
task :stop_jetty do
  jetty_params = Jettywrapper.load_config.merge({:jetty_home => File.expand_path(File.dirname(__FILE__) + '../../../solrmarc-sw/test/jetty'),:startup_wait => 10})
  error = Jettywrapper.stop(jetty_params) 
end

task :jetty_stop => :stop_jetty
