require File.expand_path('../spec_helper', __FILE__)
require 'solrj_wrapper'

describe SolrjWrapper do
  
  before(:all) do
    @solrj_wrapper = SolrjWrapper.new(@@settings.solrj_jar_dir, @@settings.solr_url, @@settings.solrj_num_threads, @@settings.log_level, @@settings.log_file)
  end
  
  it "initializes an HttpSolrServer object" do
    expect(@solrj_wrapper.http_solr_server).to be_an_instance_of(Java::OrgApacheSolrClientSolrjImpl::HttpSolrServer)
  end

  context "get_query_result_docs" do
    it "should return a SolrDocumentList object" do
      q = org.apache.solr.client.solrj.SolrQuery.new
      expect(@solrj_wrapper.get_query_result_docs(q)).to be_an_instance_of(Java::OrgApacheSolrCommon::SolrDocumentList)
    end
    
    it "should return an object of size 0 when there are no hits" do
      q = org.apache.solr.client.solrj.SolrQuery.new
      q.setQuery("zzzzzznohitszzzzzzzz")
      expect(@solrj_wrapper.get_query_result_docs(q).size).to eq 0
    end
    
    it "should return an object of size 0 when rows = 0" do
      q = org.apache.solr.client.solrj.SolrQuery.new
      q.setRows(0)
      expect(@solrj_wrapper.get_query_result_docs(q).size).to eq 0
    end

    it "should return an object of size > 1 when there are hits and rows is > 0" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_val_to_fld(sid, "id", "test_rec")
      @solrj_wrapper.add_doc_to_ix(sid, "test_rec")
      @solrj_wrapper.commit
      q = org.apache.solr.client.solrj.SolrQuery.new
      expect(@solrj_wrapper.get_query_result_docs(q).size).not_to eq 0
      @solrj_wrapper.empty_ix
    end
  end
  
  context "add_vals_to_fld" do
    it "should do nothing if the field name or value is nil or of size 0" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, nil, ["val"])
      expect(sid.isEmpty).to eq true
      @solrj_wrapper.add_vals_to_fld(sid, "", ["val"])
      expect(sid.isEmpty).to eq true
      @solrj_wrapper.add_vals_to_fld(sid, "fldname", nil)
      expect(sid.isEmpty).to eq true
      @solrj_wrapper.add_vals_to_fld(sid, "fldname", [])
      expect(sid.isEmpty).to eq true
    end
    
    it "should create a new field when none exists" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "single", ["val"])
      vals = sid["single"].getValues
      expect(vals.size).to eq 1
      expect(vals[0]).to eq "val"
      @solrj_wrapper.add_vals_to_fld(sid, "mult", ["val1", "val2"])
      vals = sid["mult"].getValues
      expect(vals.size).to eq 2
      expect(vals[0]).to eq "val1"
      expect(vals[1]).to eq "val2"
    end
    
    it "should keep the existing values when it adds a value to a field" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val"])
      vals = sid["fld"].getValues
      expect(vals.size).to eq 1
      expect(vals[0]).to eq "val"
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2"])
      vals = sid["fld"].getValues
      expect(vals.size).to eq 3
      expect(vals.contains("val")).not_to eq nil
      expect(vals.contains("val1")).not_to eq nil
      expect(vals.contains("val2")).not_to eq nil
    end
    
    it "should add all values, except those already present" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val"])
      vals = sid["fld"].getValues
      expect(vals.size).to eq 1
      expect(vals[0]).to eq "val"
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2", "val"])
      vals = sid["fld"].getValues
      expect(vals.size).to eq 3
      expect(vals.contains("val")).not_to eq nil
      expect(vals.contains("val1")).not_to eq nil
      expect(vals.contains("val2")).not_to eq nil
    end
  end # context add_vals_to_fld

  context "add_val_to_fld" do
    it "should do nothing if the field name or value is nil or of size 0" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_val_to_fld(sid, nil, "val")
      expect(sid.isEmpty).to eq true
      @solrj_wrapper.add_val_to_fld(sid, "", "val")
      expect(sid.isEmpty).to eq true
      @solrj_wrapper.add_val_to_fld(sid, "fldname", nil)
      expect(sid.isEmpty).to eq true
      @solrj_wrapper.add_val_to_fld(sid, "fldname", [])
      expect(sid.isEmpty).to eq true
    end
    
    it "should create a new field when none exists" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_val_to_fld(sid, "single", "val")
      vals = sid["single"].getValues
      expect(vals.size).to eq 1
      expect(vals[0]).to eq "val"
    end
    
    it "should keep the existing values when it adds a value to a field" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2"])
      @solrj_wrapper.add_val_to_fld(sid, "fld", "val")
      vals = sid["fld"].getValues
      expect(vals.size).to eq 3
      expect(vals.contains("val")).not_to eq nil
      expect(vals.contains("val1")).not_to eq nil
      expect(vals.contains("val2")).not_to eq nil
    end
    
    it "should add all values, except those already present" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2", "val"])
      @solrj_wrapper.add_val_to_fld(sid, "fld", "val")
      vals = sid["fld"].getValues
      expect(vals.size).to eq 3
      expect(vals.contains("val")).not_to eq nil
      expect(vals.contains("val1")).not_to eq nil
      expect(vals.contains("val2")).not_to eq nil
    end
  end # context add_vals_to_fld

  context "replace_field_values" do
    it "should work for disjoint sets of field values" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2", "val3"])
      @solrj_wrapper.replace_field_values(sid, "fld", ["val4", "val5"])
      vals = sid["fld"].getValues
      expect(vals.size).to eq 2
      expect(vals.contains("val1")).to eq false
      expect(vals.contains("val2")).to eq false
      expect(vals.contains("val3")).to eq false
      expect(vals.contains("val4")).to eq true
      expect(vals.contains("val5")).to eq true
    end

    it "should retain unchanged values" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2"])
      @solrj_wrapper.replace_field_values(sid, "fld", ["val2", "val3"])
      vals = sid["fld"].getValues
      expect(vals.size).to eq 2
      expect(vals.contains("val1")).to eq false
      expect(vals.contains("val2")).to eq true
      expect(vals.contains("val3")).to eq true
    end
    
    it "should create a field when none existed before" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      expect(sid["fld"]).to eq nil
      @solrj_wrapper.replace_field_values(sid, "fld", ["val1"])
      vals = sid["fld"].getValues
      expect(vals.size).to eq 1
      expect(vals.contains("val1")).to eq true
    end
    
    it "should remove a field if there are no values to add" do
      sid = Java::OrgApacheSolrCommon::SolrInputDocument.new
      @solrj_wrapper.add_vals_to_fld(sid, "fld", ["val1", "val2"])
      @solrj_wrapper.replace_field_values(sid, "fld", [])
      expect(sid["fld"]).to eq nil
    end
  end

end
