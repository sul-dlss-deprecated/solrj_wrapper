require File.expand_path('../spec_helper', __FILE__)
require 'solrj_wrapper'

describe SolrjWrapper do
  
  before(:all) do
    @solrj_wrapper = SolrjWrapper.new(@@settings.solrj_jar_dir, @@settings.solr_url, @@settings.solrj_queue_size, @@settings.solrj_num_threads)
  end
  
  it "should initialize a query_server object" do
    @solrj_wrapper.query_server.should be_an_instance_of(Java::OrgApacheSolrClientSolrjImpl::CommonsHttpSolrServer)
  end

  context "get_query_result_docs" do
    it "should return a SolrDocumentList object" do
      q = org.apache.solr.client.solrj.SolrQuery.new
      @solrj_wrapper.get_query_result_docs(q).should be_an_instance_of(Java::OrgApacheSolrCommon::SolrDocumentList)
    end
    
    it "should return an object of size 0 when there are no hits" do
      q = org.apache.solr.client.solrj.SolrQuery.new
      q.setQuery("zzzzzznohitszzzzzzzz")
      @solrj_wrapper.get_query_result_docs(q).size.should == 0
    end
    
    it "should return an object of size 0 when rows = 0" do
      q = org.apache.solr.client.solrj.SolrQuery.new
      q.setRows(0)
      @solrj_wrapper.get_query_result_docs(q).size.should == 0
    end

    it "should return an object of size > 1 when there are hits and rows is > 0" do
      q = org.apache.solr.client.solrj.SolrQuery.new
      @solrj_wrapper.get_query_result_docs(q).size.should_not == 0
    end
  end
  
  it "should initialize a streaming_update_server object" do
    @solrj_wrapper.streaming_update_server.should be_an_instance_of(Java::OrgApacheSolrClientSolrjImpl::StreamingUpdateSolrServer)
  end
  
  context "add_vals_to_fld" do
    it "should do nothing if the field name or value is nil or of size 0" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, nil, ["val"])
      sid.isEmpty.should be_true
      @solrj_wrapper.add_vals_to_fld(sid, "", ["val"])
      sid.isEmpty.should be_true
      @solrj_wrapper.add_vals_to_fld(sid, "fldname", nil)
      sid.isEmpty.should be_true
      @solrj_wrapper.add_vals_to_fld(sid, "fldname", [])
      sid.isEmpty.should be_true
    end
    
    it "should create a new field when none exists" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "single", ["val"])
      vals = sid["single"].getValues
      vals.size.should == 1
      vals[0].should == "val"
      @solrj_wrapper.add_vals_to_fld(sid, "mult", ["val1", "val2"])
      vals = sid["mult"].getValues
      vals.size.should == 2
      vals[0].should == "val1"
      vals[1].should == "val2"
    end
    
    it "should keep the existing values when it adds a value to a field" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val"])
      vals = sid["fld"].getValues
      vals.size.should == 1
      vals[0].should == "val"
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2"])
      vals = sid["fld"].getValues
      vals.size.should == 3
      vals.contains("val").should_not be_nil
      vals.contains("val1").should_not be_nil
      vals.contains("val2").should_not be_nil
    end
    
    it "should add all values, except those already present" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val"])
      vals = sid["fld"].getValues
      vals.size.should == 1
      vals[0].should == "val"
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2", "val"])
      vals = sid["fld"].getValues
      vals.size.should == 3
      vals.contains("val").should_not be_nil
      vals.contains("val1").should_not be_nil
      vals.contains("val2").should_not be_nil
    end
  end # context add_vals_to_fld

  context "add_val_to_fld" do
    it "should do nothing if the field name or value is nil or of size 0" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_val_to_fld(sid, nil, "val")
      sid.isEmpty.should be_true
      @solrj_wrapper.add_val_to_fld(sid, "", "val")
      sid.isEmpty.should be_true
      @solrj_wrapper.add_val_to_fld(sid, "fldname", nil)
      sid.isEmpty.should be_true
      @solrj_wrapper.add_val_to_fld(sid, "fldname", [])
      sid.isEmpty.should be_true
    end
    
    it "should create a new field when none exists" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_val_to_fld(sid, "single", "val")
      vals = sid["single"].getValues
      vals.size.should == 1
      vals[0].should == "val"
    end
    
    it "should keep the existing values when it adds a value to a field" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2"])
      @solrj_wrapper.add_val_to_fld(sid, "fld", "val")
      vals = sid["fld"].getValues
      vals.size.should == 3
      vals.contains("val").should_not be_nil
      vals.contains("val1").should_not be_nil
      vals.contains("val2").should_not be_nil
    end
    
    it "should add all values, except those already present" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2", "val"])
      @solrj_wrapper.add_val_to_fld(sid, "fld", "val")
      vals = sid["fld"].getValues
      vals.size.should == 3
      vals.contains("val").should_not be_nil
      vals.contains("val1").should_not be_nil
      vals.contains("val2").should_not be_nil
    end
  end # context add_vals_to_fld

  context "replace_field_values" do
    it "should work for disjoint sets of field values" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2", "val3"])
      @solrj_wrapper.replace_field_values(sid, "fld", ["val4", "val5"])
      vals = sid["fld"].getValues
      vals.size.should == 2
      vals.contains("val1").should be_false
      vals.contains("val2").should be_false
      vals.contains("val3").should be_false
      vals.contains("val4").should be_true
      vals.contains("val5").should be_true
    end

    it "should retain unchanged values" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2"])
      @solrj_wrapper.replace_field_values(sid, "fld", ["val2", "val3"])
      vals = sid["fld"].getValues
      vals.size.should == 2
      vals.contains("val1").should be_false
      vals.contains("val2").should be_true
      vals.contains("val3").should be_true
    end
    
    it "should create a field when none existed before" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      sid["fld"].should be_nil
      @solrj_wrapper.replace_field_values(sid, "fld", ["val1"])
      vals = sid["fld"].getValues
      vals.size.should == 1
      vals.contains("val1").should be_true
    end
    
    it "should remove a field if there are no values to add" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2"])
      @solrj_wrapper.replace_field_values(sid, "fld", [])
      sid["fld"].should be_nil
    end
  end

end
