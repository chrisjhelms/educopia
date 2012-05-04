require File.dirname(__FILE__) + '/../test_helper'

class PluginTest < ActiveSupport::TestCase
  
  def provider(opts = {}) 
    defs = {:name => "University Somewhere Other", 
            :plugin_prefix => "edu.uni", 
            :icon_url => "/images/content_providers/org.ico", 
            :acronym => "acro"};
    p = ContentProvider.new(defs.merge(opts)); 
    p.save!

    return p
  end
  
  def create(acro)
    prov = ContentProvider.find_by_acronym(acro);
    p = Plugin.new(:content_provider => prov, 
                   :name => "#{prov.plugin_prefix}.plugin")
    p.save!
    return p; 
  end
  
  def test_new
    prov = provider({}); 
    p = Plugin.new(:content_provider => prov, 
                   :name => "#{prov.plugin_prefix}.plugin")
    assert p.save
  end
  
  def test_get 
    prov = ContentProvider.find(:first); 
    assert(prov)
    p = Plugin.get(" #{prov.plugin_prefix}.plugin  ", prov); 
    assert(p); 
    p2 = Plugin.get("#{prov.plugin_prefix}.plugin", prov); 
    assert(p2)
    assert p == p2
    p3 = Plugin.get("   #{prov.plugin_prefix}.plugin", prov); 
    assert(p3)
    assert p == p3
  end
  
  def test_baseurl_param 
    prov = ContentProvider.find(:first); 
    p = Plugin.get(" #{prov.plugin_prefix}.plugin  ", prov); 
    base_url_param = p.plugin_params.select { |pp| pp.name == "base_url" }
    assert(base_url_param.length == 1)
  end 
  
  def test_name_provider_mismatch 
    prov = provider(); 
    p = Plugin.get("XXX.#{prov.plugin_prefix}.plugin", prov)
    assert p.nil?
  end
  
  def test_empty_provider 
    p = Plugin.new( :name => "edu.uni.plugin")
    assert !p.save
  end
  
  def test_double_name 
    prov = provider(); 
    p = Plugin.new(:content_provider => prov, 
                   :name => "#{prov.plugin_prefix}.plugin")
    assert p.save
    p = Plugin.new(:content_provider => prov, 
                   :name => "#{prov.plugin_prefix}.plugin")
    assert !p.save
  end
  
  def test_name=_after_save 
    prov = provider(); 
    p = Plugin.get("  #{prov.plugin_prefix}.plugin", prov)
    assert_raise p.name= "somethingelse"; 
  end
  
  def test_compact_name 
    prov = provider(); 
    p = Plugin.get("  #{prov.plugin_prefix}.plugin", prov)
    assert(p)
    p2 = Plugin.get("#{prov.plugin_prefix}.plugin", prov)
    assert(p2) 
    assert(p == p2);
  end
  
  def test_belongs_to
    prov = provider(); 
    p = Plugin.get("#{prov.plugin_prefix}.plugin", prov)
    assert_equal(p.content_provider, prov)
    assert p.content_provider.plugins.include?(p)
  end
  
  def test_param_value_matcher
    prov = provider(); 
    str_param = {:kind => "string", :descr => "string something or other" }
    card_param = {:kind => "cardinal", :descr => "card something or other" }
    p = Plugin.get("#{prov.plugin_prefix}.plugin", prov)
    p.merge_params({'volume' =>  str_param, 'card' => card_param})
    p.save!
    
    values = { "base_url" => "http://jhgajhsdga.edu", "volume" => "string_value", "card" => 12}
    errs = p.param_values_match?(values)
    assert(errs.empty?); 
    
    values = { "volume" => "string_value", "card" => 12}
    errs = p.param_values_match?(values)
    assert(errs.length == 1); 
    
    values = { "card" => 12}
    errs = p.param_values_match?(values)
    assert(errs.length == 2); 
    
    values = { "x" => "can't give this one", "base_url" => "http://jhgajhsdga.edu", "volume" => "string_value", "card" => 12}
    errs = p.param_values_match?(values)
    assert(errs.length == 1); 
    
  end
  
  def test_access_one_by_user
    obj = create("one"); 
    
    assert UserTestHelper.user_may_update(obj, "super") ;
    assert UserTestHelper.user_may_update(obj, "one_edit"); 
    assert UserTestHelper.user_may_update(obj, "one_view") == false; 
  end 
 
  def test_access_two_by_user 
    obj = create("two"); 
    assert UserTestHelper.user_may_update(obj, "super");
    assert UserTestHelper.user_may_update(obj, "one_edit") == false; 
    assert UserTestHelper.user_may_update(obj, "one_view") == false; 
  end
end
