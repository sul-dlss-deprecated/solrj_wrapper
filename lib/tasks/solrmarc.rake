namespace :sj_wrap do
  namespace :solrmarc do
    require 'ant'
    
    desc "run ant dist_site target in solrmarc"
    task :ant_dist_site do
      ant '-f solrmarc/build.xml dist_site'
    end
    
    desc "run ant target to set up testing jetty per straight solrmarc"
    task :setup_test_jetty do
      ant '-f solrmarc/build.xml test_clean_site'
      ant '-f solrmarc/build.xml site_setup_test_jetty'
    end

  end
end