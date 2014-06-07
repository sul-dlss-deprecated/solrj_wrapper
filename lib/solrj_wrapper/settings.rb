require 'yaml'

# Read the .yml file containing the configuration values
class Settings
  
  attr_reader :solr_url, :solrj_jar_dir, :log_level, :log_file
  
  def initialize(settings_group)
    yml = YAML.load_file('lib/config/settings.yml')[settings_group]
    @solr_url = yml["solr_url"]
    @solrj_jar_dir = yml["solrj_jar_dir"]
    @log_level = yml["log_level"]
    @log_file = yml["log_file"]
  end
  
  # @return the attributes of this class as a Hash
  def as_hash
    {:solr_url => @solr_url,
      :solrj_jar_dir => @solrj_jar_dir,
      :log_level => get_log_level, 
      :log_file => @log_file
       }
  end
  
  def get_log_level
    case (@log_level)
      when "debug"
        logger_level = Logger::DEBUG
      when "warn"
        logger_level = Logger::WARN
      when "error"
        logger_level = Logger::ERROR
      when "fatal"
        logger_level = Logger::FATAL
      else
        logger_level = Logger::INFO
    end
    logger_level
  end
  
end