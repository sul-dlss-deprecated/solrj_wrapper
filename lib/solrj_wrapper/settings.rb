require 'yaml'

# Read the .yml file containing the configuration values
class Settings
  
  attr_reader :solr_url, :solrj_jar_dir, :solrj_queue_size, :solrj_num_threads
  
  def initialize(settings_group)
    yml = YAML.load_file('lib/config/settings.yml')[settings_group]
    @solr_url = yml["solr_url"]
    @solrj_jar_dir = yml["solrj_jar_dir"]
    @solrj_queue_size = yml["solrj_queue_size"]
    @solrj_num_threads = yml["solrj_num_threads"]
  end
  
  # @return the attributes of this class as a Hash
  def as_hash
    {:solr_url => @solr_url,
      :solrj_jar_dir => @solrj_jar_dir,
      :solrj_queue_size => @solrj_queue_size,
      :solrj_num_threads => @solrj_num_threads }
  end
  
end