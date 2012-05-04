require File.dirname(__FILE__) + '/../test_helper'

class PluginTest < ActiveSupport::TestCase
  fixtures :archives, :content_providers;

  def plugin(opts = {}) 
    prov = ContentProvider.find(:first);
    p = Plugin.get("#{prov.plugin_prefix}.plugin", prov); 
    return p
  end
  
  def test_new
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :name => "name", :kind => "string"); 
    assert p.save
  end
  
  def test_empty_plugin 
    p = PluginParam.new(:plugin => nil, 
                        :name => "name", :kind => "string"); 
    assert !p.save
    p = PluginParam.new(:name => "name", :kind => "string"); 
    assert !p.save
  end
  
  def test_empty_name
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :kind => "string"); 
    assert !p.save
  end
  
  def test_empty_kind
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :name => "name"); 
    assert !p.save
  end
  
  def test_double_name 
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :name => "name", :kind => "string"); 
    assert p.save
    
    p = PluginParam.new(:plugin => plugn, 
                        :name => "name", :kind => "string"); 
    assert !p.save
  end
  
  def test_plugin=_after_save 
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :name => "name", :kind => "string"); 
    assert p.save
    assert_raise p.plugin= "somethingelse"; 
  end
  
  def test_compact_name 
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :name => "  name    ", :kind => "string"); 
    
    assert(p)
    assert(p.name == "name"); 
  end
  
  def test_compact_kind 
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :name => "  name    ", :kind => "  string "); 
    
    assert(p)
    assert(p.kind == "string"); 
  end
  
  def test_belongs_to
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :name => "  name    ", :kind => "  string "); 
    assert(p)
    assert(p.save)
    assert_equal(p.plugin, plugn)
    assert p.plugin.plugin_params.include?(p)
  end
  
  def test_plugin_destroys 
    plugn = plugin(); 
    p = PluginParam.new(:plugin => plugn, 
                        :name => "x", :kind => "string"); 
    assert p.save
    
    p = PluginParam.new(:plugin => plugn, 
                        :name => "y", :kind => "string"); 
    assert p.save
    
    pid = plugn.id;
    plugn.destroy();
    assert(PluginParam.find(:all, :conditions  => { :plugin_id => pid }).length == 0); 
  end
  
end
