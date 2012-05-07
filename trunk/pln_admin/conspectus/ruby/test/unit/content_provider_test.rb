require File.dirname(__FILE__) + '/../test_helper'

class ContentProviderTest < ActiveSupport::TestCase
  
  def test_create
    c = ContentProvider.new(:name => "University Somewhere Library", 
    :plugin_prefix => "edu.uni.library", 
    :icon_url => "/images/content_providers/aub.ico", 
    :acronym => "uni"); 
    assert c.save!
    
    c = ContentProvider.new(:name => "University Somewhere", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/org.ico", 
    :acronym => "unie");
    assert c.save!
  end
  
  def test_http_favicon
    c = ContentProvider.new(:name => "University Somewhere Library", 
    :plugin_prefix => "edu.uni.library", 
    :icon_url => "http://www.metaarchive.org/favicon.ico", 
    :acronym => "uni"); 
    assert c.save!
  end
  
  def test_empty_name 
    c = ContentProvider.new(
                            :plugin_prefix => "edu.uni.library", 
    :icon_url => "/images/content_providers/em.ico",  :acronym => "uni"); 
    assert !c.save
  end 
  
  def test_empty_acronym 
    c = ContentProvider.new(
                            :name => "University Somewhere", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/em.ico");
    assert !c.save
  end 
  
  def test_empty_plugin_prefix 
    c = ContentProvider.new(:name => "University Somewhere Library", 
    :icon_url => "/images/content_providers/em.ico",  :acronym => "uni"); 
    assert !c.save
  end 
  
  def test_empty_icon_url
    c = ContentProvider.new(:name => "University Somewhere", 
    :plugin_prefix => "edu.uni"); 
    assert !c.save
  end 
  
  def test_no_double_name 
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/em.ico",  :acronym => "uni"); 
    assert c.save!
    
    # test no double names
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "edu.uni2", 
    :icon_url => "/images/content_providers/em.ico",  :acronym => "uni"); 
    assert !c.save
  end 
  
  def test_no_double_plugin_prefix
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/em.ico",  :acronym => "uni"); 
    assert c.save!
    
    # test no double names
    c = ContentProvider.new(:name => "University Somewhere Other", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/aub.ico", :acronym => "acro"); 
    assert !c.save
  end 
  
  def test_long_acronym
    c = ContentProvider.new(:name => "University Somewhere", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/em.ico", 
    :acronym => "acro");
    assert c.save
    
    c = ContentProvider.new(:name => "University Somewhere", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/em.ico", 
    :acronym => "acrob");
    assert !c.save
  end 
  
  def test_short_acronym 
    c = ContentProvider.new(:name => "University Somewhere", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/em.ico", 
    :acronym => "");
    assert !c.save
  end 
  
  def test_bad_plugin_prefix
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => nil, 
    :icon_url => "/images/content_providers/aub.ico", :acronym => "acro"); 
    assert !c.save   
    
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "", 
    :icon_url => "/images/content_providers/aub.ico", :acronym => "acro"); 
    assert !c.save   
    
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "edu-some", 
    :icon_url => "/images/content_providers/aub.ico", :acronym => "acro"); 
    assert !c.save   
  end 
  
  def test_change_plugin_prefix
    c = ContentProvider.new(:name => "University Somewhere Library", 
        :plugin_prefix => "edu.uni.library", 
        :icon_url => "/images/content_providers/aub.ico", 
        :acronym => "uni"); 
     assert c.save!
     
     c.plugin_prefix = "edu.other.library";
     assert c.save! 
     
    assert(c.placeholder_plugin.name.match(/^edu\.other\.library/) != nil)
  end
  
  def test_cant_change_plugin_prefix 
    c = ContentProvider.new(:name => "University Somewhere Library", 
        :plugin_prefix => "edu.uni.library", 
        :icon_url => "/images/content_providers/aub.ico", 
        :acronym => "uni"); 
    assert c.save! 
    assert (Plugin.get("#{c.plugin_prefix}.eins.plugin",c))
    
    # has plugin  ==> can update plugin prefix  
    assert_raise ( RuntimeError) {
      c.plugin_prefix = "edu.other.library";
      c.save! 
    }
  end
  
  def test_no_double_icon
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "edu.uni", 
    :icon_url => "/images/content_providers/aub.ico", 
    :acronym => "acro"); 
    assert c.save!
    
    # test no double names
    c = ContentProvider.new(:name => "University Somewhere Other", 
    :plugin_prefix => "org.uni", 
    :icon_url => "/images/content_providers/aub.ico", :acronym => "acro"); 
    assert !c.save
  end 
  
  def test_bad_icons
    # bad extension
    c = ContentProvider.new(:name => "University Somewhere edu",  
                     :plugin_prefix => "edu.some",  
                     :icon_url => "/images/content_providers/vt.ixo", 
                     :acronym => "bcro") 
    assert !c.save   
    
    # non existing file 
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "edu.some", 
    :icon_url => "/images/content_providers/does_not_exist.ixo", :acronym => "bcro"); 
    assert !c.save   

    # empty icon
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "edu.uni.library",  
    :icon_url => "", 
    :acronym => "acro"); 
    assert !c.save   
    
    c = ContentProvider.new(:name => "University Somewhere edu", 
    :plugin_prefix => "edu.some", 
    :icon_url => "/images/content_providers/928179278291.ixo", :acronym => "ccro"); 
    assert !c.save
   
  end 
  
  def test_destroy
    a = Archive.find(:first); 
    prov = ContentProvider.new(:name => "Uni Somewhere edu", 
    :plugin_prefix => "edu", 
    :icon_url => "/images/content_providers/za.ico", :acronym => "acro"); 
    assert prov.save 
    id = prov.id;
    # has no collections ==> can destroy 
    prov.destroy
    assert( Plugin.find(:first, :conditions => { :content_provider_id => id } ) == nil ); 
    
    prov = ContentProvider.new(:name => "University Somewhere edu", 
                               :plugin_prefix => "edu", 
                               :icon_url => "/images/content_providers/aub.ico", 
                               :acronym => "acro");  
    assert prov.save 
    
    url = "http://some.where.edu/collections/location"
    coll = Collection.new(:archive =>a, 
                          :plugin => Plugin.get("#{prov.plugin_prefix}.eins.plugin",prov),
                          :base_url => url,
                          :title => "collection",
                          :description => "whatever")
    assert coll.save!
    # has collection ==> can not destroy 
    assert_raise ( RuntimeError) {
      prov.destroy 
    }
  end
end
