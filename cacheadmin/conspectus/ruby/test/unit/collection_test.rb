require File.dirname(__FILE__) + '/../test_helper'

class CollectionTest < ActiveSupport::TestCase
  fixtures :archives, :content_providers, :plugins;
 
  def test_create(acro = "one")
    a = Archive.find(:first); 
    prov = ContentProvider.find_by_acronym(acro);  
    url = "http://some.where.edu/collections/location"
    
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get("#{prov.plugin_prefix}.eins.plugin",prov),
                      :base_url => url, 
                      :title => "collection",
                      :description => "whatever")
    assert c.save!
    p = Plugin.find_by_name("#{prov.plugin_prefix}.eins.plugin")
    assert (p.id >= 1)
    
    return c;
  end
  
  def test_access_one_by_user
    obj = test_create("one"); 
    
    assert UserTestHelper.user_may_update(obj, "super") ;
    assert UserTestHelper.user_may_update(obj, "one_edit"); 
    assert UserTestHelper.user_may_update(obj, "one_view") == false; 
  end 
 
  def test_access_two_by_user 
    obj = test_create("two"); 
    assert UserTestHelper.user_may_update(obj, "super");
    assert UserTestHelper.user_may_update(obj, "one_edit") == false; 
    assert UserTestHelper.user_may_update(obj, "one_view") == false; 
  end
  
  def test_relations
    a = Archive.find(:first)
    prov = ContentProvider.find(:first) 
    url = "http://some.where.edu/collections/location"
    p = Plugin.get(" #{prov.plugin_prefix}.eins.plugin ", prov)
    assert(p); 
    
    c = Collection.new(:archive =>a,  
                       :plugin => p,
                       :base_url => url, 
                       :title => "collection for relations")
    assert_equal c.archive, a 
    assert_equal c.plugin, p
    assert c.save
    assert_equal c.content_provider, p.content_provider 
    assert prov.collections.include?(c)    
    assert p.collections.include?(c)
  end
  
  def test_plugin_change
    a = Archive.find(:first)
    prov = ContentProvider.find(:first) 
    url = "http://some.where.edu/collections/location"
    p1 = Plugin.get(" #{prov.plugin_prefix}.eins.plugin ", prov)
    p2 = Plugin.get(" #{prov.plugin_prefix}.zwei.plugin ", prov)
    
    c = Collection.new(:archive =>a,  
                       :plugin => p1,
                       :base_url => url, 
                       :title => "collection")
    assert c.save
    c.plugin= p2; 
    assert Plugin.find_by_name(" #{prov.plugin_prefix}.eins.plugin ").nil?
  end
  
  def test_baseurl_change
    a = Archive.find(:first)
    prov = ContentProvider.find(:first) 
    url = "http://some.where.edu/"
    p1 = Plugin.get(" #{prov.plugin_prefix}.eins.plugin ", prov)
    
    c = Collection.new(:archive =>a,  
                       :plugin => p1,
                       :base_url => url, 
                       :title => "collection")
    c.save!
    c.base_url = c.base_url + "/more"; 
    c.save!
    
    au = ArchivalUnit.new(:collection => c, :param_values => {})
    au.save! 
    c = Collection.find(c.id);
    c.base_url = c.base_url + "/more"; 
    c.save! 
    
    c.archival_units[0].au_state = AuState.get(AuState::PRESERVED)
    c.archival_units[0].save(false); 
    assert_raise RuntimeError do
       c.base_url = c.base_url + "/more"; 
    end
  end
  
  def test_unique_title_in_content_provider 
    a1 = Archive.find(:first)
    a2 = archives(:arch2)
    prov = ContentProvider.find(:first) 
    url = "http://some.where.edu/collections/location"
    p1 = Plugin.get(" #{prov.plugin_prefix}.eins.plugin ", prov);
    
    c = Collection.new(:archive =>a1,  
                       :plugin => p1,
                       :base_url => url, 
                       :title => "collection a1 p1")
    assert c.save
    
    c = Collection.new(:archive =>a1,  
                       :plugin => p1,
                       :base_url => url, 
                       :title => "collection a1 p1")
    assert !c.save
    
    c = Collection.new(:archive =>a2,  
                       :plugin => p1,
                       :base_url => url, 
                       :title => "collection a1 p1")
    assert !c.save
  end
  
  def test_nil_plugin 
    a = archives(:arch1) 
    url = "http://some.where.edu/collections/location"
    
    # nil plugin
    assert_raise RuntimeError do 
      c = Collection.new(:plugin => nil,
                         :archive =>a, 
                         :base_url => url, 
                         :title => "collection")
    end
  end 
  
  def test_no_archive
    prov = content_providers(:one);
    url = "http://some.where.edu/collections/location"
    c = Collection.new(:plugin => Plugin.get("#{prov.plugin_prefix}.eins.plugin", prov),
    :base_url => url, 
    :title => "collection")
    assert !c.save
  end 
  
  def test_no_base_url
    a = archives(:arch1) 
    prov = content_providers(:one);
    
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get("#{prov.plugin_prefix}.eins.plugin", prov),
    :title => "collection")
    assert !c.save
  end 
  
  def test_no_title
    a = archives(:arch1) 
    prov = content_providers(:one);
    url = "http://some.where.edu/collections/location"
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get("#{prov.plugin_prefix}.eins.plugin", prov),
    :base_url => url)
    assert !c.save
  end
  
  def test_title_uniqueness
    a1 = Archive.find(:first)
    prov1 = ContentProvider.find(:first); 
    p1 = Plugin.get("#{prov1.plugin_prefix}.eins.plugin  ", prov1)   
    assert(p1) 
    
    a2 = Archive.find(:all)[1]
    prov2 = ContentProvider.find(:all)[1]; 
    p2 = Plugin.get("#{prov2.plugin_prefix}.eins.plugin  ", prov2)   
    assert(p2)
    assert(p1 != p2);
    
    url = "http://some.where.edu/collections/location"
    
    
    c = Collection.new(:archive =>a1, 
                       :plugin =>  p1,
                       :base_url => url, 
                       :title =>  " collection      ", 
    :description => "create first version") 
    assert c.save
    
    
    # can create in other archive with different content_provider 
    c = Collection.new(:archive => a2, 
                       :plugin => p2,
                       :base_url => url, 
                       :title => "     collection ", 
    :description => "create second version")
    assert c.save
    
    # can not create in same archive 
    c = Collection.new(:archive => a1, 
                       :plugin => p1,
                       :base_url => url, 
                       :title => "   collection ", 
    :description => "create third version")
    assert !c.save
    
  end
  
  def test_base_url_proper_format
    a = Archive.find(:first)
    prov = ContentProvider.find(:first); 
    url = "http//some.where.edu/collections/location"
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get("#{prov.plugin_prefix}.eins.plugin", prov),
    :base_url => url, 
    :title => "collection",
    :description => "whatever")
    assert !c.save
    
    url = "http:/location"
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get("#{prov.plugin_prefix}.eins.plugin", prov), 
    :base_url => url, 
    :title => "collection",
    :description => "whatever")
    assert !c.save
    
    url = "http:///location"
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get("#{prov.plugin_prefix}.eins.plugin", prov),
    :base_url => url, 
    :title => "collection",
    :description => "whatever")
    assert !c.save
  end
  
  def test_find_plugin_baseurl
    a = Archive.find(:first); 
    prov = ContentProvider.find(:first); 
    url = "http://some.where.edu/collections/location"
    plugin = "#{prov.plugin_prefix}.eins.plugin";
    
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get(plugin, prov),
    :base_url => url, 
    :title => "collection",
    :description => "whatever")
    assert c.save!
    cf =  Collection.find_by_plugin_baseurl(plugin, url)
    assert(c == cf[0]);
    
    cf =  Collection.find_by_plugin_baseurl(plugin.chop, url)
    assert(cf.empty?);
    
    cf =  Collection.find_by_plugin_baseurl(plugin, url.chop)
    assert(cf.empty?);
  end
  
  def test_destroy_collection
    a = Archive.find(:first); 
    prov = ContentProvider.find(:first); 
    url = "http://some.where.edu/collections/location"
    plugin = "#{prov.plugin_prefix}.eins.plugin";
    
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get(plugin, prov),
                       :base_url => url, 
                       :title => "collection",
                        :description => "whatever")
    assert c.save!
    c.destroy
    cf =  Collection.find_by_plugin_baseurl(plugin.chop, url)
    assert(cf.empty?);
     
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get(plugin, prov),
                       :base_url => url, 
                       :title => "collection",
                        :description => "whatever")
    assert c.save!
    au = ArchivalUnit.new(:collection => c, 
                          :param_values => {})
    au.save!
    assert_raise RuntimeError do
        c.destroy
    end 
  end
  
  
  def test_retire_collection
    a = Archive.find(:first); 
    prov = ContentProvider.find(:first); 
    url = "http://some.where.edu/collections/location"
    plugin = "#{prov.plugin_prefix}.eins.plugin";
    
    # can retire collection without aus 
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get(plugin, prov),
                       :base_url => url, 
                       :title => "collection",
                        :description => "whatever")
    assert c.save!
    c.retired = true
    c.save! 
    
    # can not add au to retired collection 
    au = ArchivalUnit.new(:collection => c, 
                          :param_values => {})
    assert_raise RuntimeError do
      au.save!
    end 
    
    c = Collection.new(:archive =>a, 
                       :plugin => Plugin.get(plugin, prov),
                       :base_url => url, 
                       :title => "collection else",
                        :description => "whatever else")
    c.save!;
    
    # can't retire collection with actively preserved aus 
    au = ArchivalUnit.new(:collection => c, 
                          :param_values => {})
    au.au_state = AuState.get(AuState::PRESERVED); 
    au.assume_super_user = true;
    au.save!
    c.retired = true; 
    assert_raise RuntimeError do
      c.save!
    end 
    
    # can retire collection with retired aus 
    c.retired = false; 
    au.off_line = true;
    au.assume_super_user = true;
    au.save!
    au.au_state = AuState.get(AuState::RETIRED); 
    au.save!
    c.reload; 
    c.retired = true; 
    c.save! 
    
  end    
end
