include Java

require "solrj_wrapper/version"
require 'logger'

# Methods required to interact with SolrJ objects, such as org.apache.solr.client.solrj.impl.StreamingUpdateSolrServer
class SolrjWrapper
  
  attr_reader :streaming_update_server, :query_server
  attr_accessor :query
  
  # @param solrj_jar_dir  the location of Solrj jars needed to use SolrJ here
  # @param solr_url  base url of the solr instance
  # @param queue_size the number of Solr documents to buffer before writing to Solr
  # @param num_threads the number of threads to use when writing to Solr (should not be more than the number of cpu cores avail) 
  # @param log_level  level of Logger messages to output; defaults to Logger::INFO
  # @param log_file  file to receive Logger output; defaults to STDERR
  def initialize(solrj_jar_dir, solr_url, queue_size, num_threads, log_level=Logger::INFO, log_file=STDERR)
    if not defined? JRUBY_VERSION
      raise "SolrjWrapper only runs under jruby"
    end
    @logger = Logger.new(log_file)
    @logger.level = log_level
    load_solrj(solrj_jar_dir)
    @query_server = org.apache.solr.client.solrj.impl.HttpSolrServer.new(solr_url)
    @streaming_update_server = @query_server 
  end

  # send the query to Solr and get the SolrDocumentList from the response
  # @param org.apache.solr.client.solrj.SolrQuery object populated with query information to send to Solr
  # @return Java::OrgApacheSolrCommon::SolrDocumentList per the query.  The list size will be the number of rows in the Solr response
  def get_query_result_docs(query_obj)
    response = @query_server.query(query_obj)
    response.getResults
  end
  
  # Send requests using the Javabin binary format instead of serializing to XML
  # Requires /update/javabin to be defined in solrconfig.xml as
  # <requestHandler name="/update/javabin" class="solr.BinaryUpdateRequestHandler" />
  def useJavabin!
    @streaming_update_server.setRequestWriter Java::org.apache.solr.client.solrj.impl.BinaryRequestWriter.new
  end

  # given a SolrInputDocument, add the field and/or the values.  This will not add empty values, and it will not add duplicate values
  # @param solr_input_doc - the SolrInputDocument object receiving a new field value
  # @param fld_name - the name of the Solr field
  # @param val_array - an array of values for the Solr field
  def add_vals_to_fld(solr_input_doc, fld_name, val_array)
    unless val_array.nil? || solr_input_doc.nil? || fld_name.nil?
      val_array.each { |value|  
        add_val_to_fld(solr_input_doc, fld_name, value)
      }
    end
  end

  # given a SolrInputDocument, add the field and/or the value.  This will not add empty values, and it will not add duplicate values
  # @param solr_input_doc - the SolrInputDocument object receiving a new field value
  # @param fld_name - the name of the Solr field
  # @param value - the value to add to the Solr field
  def add_val_to_fld(solr_input_doc, fld_name, value)
    if !solr_input_doc.nil? && !fld_name.nil? && fld_name.size > 0 && !value.nil? && value.size > 0
      if !solr_input_doc[fld_name].nil? && solr_input_doc
        existing_vals = solr_input_doc[fld_name].getValues
      end
      if existing_vals.nil? || !existing_vals.contains(value)
        solr_input_doc.addField(fld_name, value, 1.0)
      end
    end
  end

  # given a SolrInputDocument, replace all the values of the field with the new values.  
  #  If the values to be added are an empty array, the field will be removed.
  #  If the field doesn't exist in the document, then it will be created (if the value array isn't empty)
  # @param solr_input_doc - the SolrInputDocument object receiving a new field value
  # @param fld_name - the name of the Solr field
  # @param value - an array of values for the Solr field
  def replace_field_values(solr_input_doc, fld_name, val_array)
    solr_input_doc.removeField(fld_name)
    add_vals_to_fld(solr_input_doc, fld_name, val_array)
  end

  # add the doc to Solr by calling add on the Solrj StreamingUpdateServer object
  # @param solr_input_doc - the SolrInputDocument to be added to the Solr index
  # @param id - the id of the Solr document, used for log messages
  def add_doc_to_ix(solr_input_doc, id)
    unless solr_input_doc.nil?
      begin
        @streaming_update_server.add(solr_input_doc)
        @logger.info("updating Solr document #{id}")        
      rescue org.apache.solr.common.SolrException => e 
        @logger.error("SolrException while indexing document #{id}")
        @logger.error("#{e.message}")
        @logger.error("#{e.backtrace}")
      end
    end
  end
  
  # send a commit to the Solrj StreamingUpdateServer object
  def commit
    begin
      update_response = @streaming_update_server.commit
    rescue org.apache.solr.common.SolrException => e
      @logger.error("SolrException while committing updates")
      @logger.error("#{e.message}")
      @logger.error("#{e.backtrace}")
    end
  end
  
  # remove all docs from the Solr index.  Assumes default request handler has type dismax
  def empty_ix
    delete_response = @streaming_update_server.deleteByQuery("*:*")
    commit
  end


protected 

  # require all the necessary jars to use Solrj classes
  def load_solrj(solrj_jar_dir)
    Dir["#{solrj_jar_dir}/*.jar"].each {|jar_file| require jar_file }
  end

end