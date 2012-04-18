namespace :sj_wrap do

  desc "run continuous integration suite (tests, coverage, docs)" 
  task :ci do 
    Rake::Task["sj_wrap:rspec_wrapped"].invoke
    Rake::Task["sj_wrap:doc"].invoke
  end

end
