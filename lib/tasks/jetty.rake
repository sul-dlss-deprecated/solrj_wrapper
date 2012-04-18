require 'jettywrapper'

namespace :sj_wrap do
  namespace :jetty do
    
    desc "Modify test jetty solr to be multicore"
    task :config => ['sj_wrap:solrmarc:setup_test_jetty'] do

      # copy the solr.xml file for multi-core to test jetty solr
      jetty_solr_dir = "solrmarc/test/jetty/solr" 
      cp('spec/solr/solr.xml', jetty_solr_dir, :verbose => true)

      # set up solr dev and test conf directories
      dev_conf_dir = "#{jetty_solr_dir}/dev/conf"
      test_conf_dir = "#{jetty_solr_dir}/test/conf"
      mkdir_p(dev_conf_dir) unless Dir.exists?(dev_conf_dir)
      mkdir_p(test_conf_dir) unless Dir.exists?(test_conf_dir)
      single_core_conf_dir = "#{jetty_solr_dir}/conf"
      Dir["#{single_core_conf_dir}/*"].each { |f| 
        cp_r(f, dev_conf_dir, :verbose => true)
        cp_r(f, test_conf_dir, :verbose => true)
      }
      
      require 'fileutils'
      # remove single core conf directory
      FileUtils.rm_rf("#{jetty_solr_dir}/conf/.", :verbose => true)
      Dir.foreach(jetty_solr_dir + "/conf") { |f| 
        fn = File.join(jetty_solr_dir, f)
        File.delete(fn) if f != '.' && f != '..'
      }
      
    end

    desc "Copies the SOLR config files and starts up the test-jetty instance"
    task :load => [:config, 'jetty:start']

  end
end