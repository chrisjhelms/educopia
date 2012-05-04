require File.dirname(__FILE__) + '/../test_helper'

class PreservationStatusItemTest < ActiveSupport::TestCase
  def test_attach_new_preservation_item
    au = ArchivalUnit.find(:first); 
    pi = PreservationStatusItem.get(:archival_unit_id => au.id, 
      :cache => "cache", 
      :hostname => "host", 
      :ui_port => 8081, 
      :disk_usage =>  10.4, 
      :size => 10, 
      :num_recent_polls => 0);   
    pi.save!
    assert pi.archival_unit == au; 
    assert au.preservation_status_items.include?(pi) 
  end
  
  def test_update_preservation_item
    au = ArchivalUnit.find(:first); 
    pi = PreservationStatusItem.get(:archival_unit_id => au.id, 
      :cache => "cache", 
      :hostname => "host", 
      :ui_port => 8081, 
      :disk_usage =>  10.4, 
      :size => 10, 
      :num_recent_polls => 0);   
    pi.save!
    au.reload
    assert pi.archival_unit == au; 
    assert au.preservation_status_items.include?(pi) 
    n = PreservationStatusItem.count; 
    pi = PreservationStatusItem.get(:archival_unit_id => au.id, 
      :cache => "cache", 
      :hostname => "host", 
      :ui_port => 8081, 
      :disk_usage =>  1000.00, 
      :size => 1000, 
      :num_recent_polls => 10);   
    pi.save!;
    assert(n == PreservationStatusItem.count);
    assert(pi.disk_usage == 1000.00)
  end
  
  def test_no_new_method
    au = ArchivalUnit.find(:first); 
    
    assert_raise(NoMethodError) { 
       pi = PreservationStatusItem.new(:archival_unit_id => au.id, 
      :cache => "cache", 
      :hostname => "hostname", 
      :ui_port => 8081, 
      :disk_usage =>  1000.00, 
      :size => 1000, 
      :num_recent_polls => 10);   
    }
  end
  
  private
  def ingestStatusXml(au, fname)
    # this test assumes that au is the only au with preservation items 
    f = File.new(fname);
    doc = REXML::Document.new(f);
    aus = doc.elements.to_a("/archival_units/archival_unit")
    assert(aus.length == 1); 
    nitems = aus[0].elements.to_a("cache_archival_units/cache_archival_unit").length
    nitems = PreservationStatusItem.update_archival_unit_from_xml(au, aus[0]); 
    au = ArchivalUnit.find(au); 
    assert au.preservation_status_items.length == nitems; 
    au.preservation_status_items.each { |i| 
      assert(i.archival_unit == au)
    }
    return au, nitems; 
  end
  
  public
  def test_statusFromXml 
    assert PreservationStatusItem.count == 0; 
    au = ArchivalUnit.find(:first); 
    au, nitems = ingestStatusXml(au, "test/files/folger_status.xml") 
    assert PreservationStatusItem.count == nitems; 
  end 
  
  def test_statusFromNoReplicationsXml 
    assert PreservationStatusItem.count == 0; 
    au = ArchivalUnit.find(:first); 
    au, nitems = ingestStatusXml(au, "test/files/folger_status_no_replications.xml") 
    assert PreservationStatusItem.count == nitems; 
  end 
  
  def test_statusFromXmlTwice 
    assert PreservationStatusItem.count == 0; 
    au = ArchivalUnit.find(:first); 
    au, nitems = ingestStatusXml(au, "test/files/folger_status.xml") 
    assert PreservationStatusItem.count == nitems; 
    au, nitems = ingestStatusXml(au, "test/files/folger_status.xml") 
    assert PreservationStatusItem.count == nitems; 
  end
  
  def test_statusFromBrokenXml 
    au = ArchivalUnit.find(:first); 
    assert_raise REXML::ParseException do
       ingestStatusXml(au, "test/files/folger_status_broken.xml") 
    end
  end 
  
  def test_statusFromBadFieldXml 
    au = ArchivalUnit.find(:first); 
    assert_raise RuntimeError do
       ingestStatusXml(au, "test/files/folger_status_bad_field.xml") 
    end
  end 
  
end
