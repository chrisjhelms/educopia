require File.dirname(__FILE__) + '/../test_helper'

class ArchivalUnitTest < ActiveSupport::TestCase
  fixtures :content_providers, :archives; 
  
  def collection(name, plugin_params = [], save_col = true) 
    prov = ContentProvider.find(:first) 
    arch = Archive.find(:first)
    plug = Plugin.get("#{prov.plugin_prefix}.eins.plugin",prov)
    plugin_params.each { |pp| 
        PluginParam.new(:plugin => plug, 
                        :name => pp[:name], :kind => pp[:kind], :descr => "#{pp[:kind]} param").save; 
    }
    col = Collection.new(:archive => arch,
                       :plugin => plug,
                       :base_url => "http://#{arch.title}.org/#{plug.name}", 
                       :title => name, 
                       :description => "whatever")
    if (save_col) then
      col.save!
    end 
    return col;
  end
  
  def test_create_good_aus 
    col = collection("base_url only"); 
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {})
    au.save!
    col.save!
    assert au.collection == col;
    assert col.archival_units.include?(au) 
      
    col = collection("year param too", [{:name => "year", :kind => "string"}])
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"year" => "2001"})
    au.save!
    col.save!
    assert au.collection == col;
    assert col.archival_units.include?(au) 
  end
  
  
  def test_load_aus_from_csv_from_to
    col = collection("with from_to", [{:name => "from", :kind => "string"}, 
                                      {:name => "to", :kind => "string"}])
    
    col.load_aus_from_csv("test/files/au_from_to.csv"); 
    assert(col.errors.empty?); 
    col = Collection.find(col.id);    
    assert(col.archival_units.length > 0); 
    
    naus = (col.archival_units.length) ;
    assert !col.load_aus_from_csv("test/files/au_from_to.csv"); 
    assert(col.archival_units.length == naus);
  end
  
  
  def test_load_aus_from_csv_volume_name
    filename = "test/files/au_volume_names.csv";
    col = collection("with volume_name", [{:name => "volume_name", :kind => "string"}])
    col.load_aus_from_csv(filename); 
    assert(col.errors.empty?); 
    col = Collection.find(col.id);   
    params = CSV.read(filename)  
    assert(col.archival_units.length() == (params.length() -1))
    
    naus = (col.archival_units.length) ;
    assert !  col.load_aus_from_csv("test/files/au_volume_names.csv"); 
    assert(col.archival_units.length == naus); 
    
    assert !col.load_aus_from_csv("test/files/au_from_to.csv"); 
    assert(col.archival_units.length == naus); 
    
    assert !col.load_aus_from_csv("test/files/au_empty.csv"); 
    assert(col.archival_units.length == naus); 
    
  end
  
  def test_initial_state
    col = collection("base_url only"); 
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {})
    au.save!
    assert(au.au_state.level == 0); 
  end
  
  def test_dont_save_au_extra_param
    col = collection("base_url only"); 
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"year" => "2001"})
    assert !au.save
    
    col = collection("year param too", [{:name => "year", :kind => "string"}])
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"year" => "2001", "extra" => "not there"})
    assert !au.save
  end 
  
  def test_dont_save_au_missing_param
    col = collection("year param too", [{:name => "year", :kind => "string"}])
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {})
    assert !au.save
  end 
  
  def test_dont_save_double_base_url
    col = collection("base_url only");
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"base_url" => "2001"})
    assert !au.save
    
    col = collection("year param too", [{:name => "year", :kind => "string"}])
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"base_url" => "2001"})
    assert !au.save
    
  end 
  
  def test_dont_save_new_going_offline
    col = collection("base_url only");
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"base_url" => "2001"})
    au.off_line = true; 
    assert !au.save
  end 
  
  def test_dont_save_test_going_offline
    col = collection("base_url only");
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"base_url" => "2001"})
    au.au_state = AuState.get(AuState::TEST);
    au.off_line = true; 
    assert !au.save
  end 
  
  def test_dont_save_retired_online
    col = collection("base_url only");
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"base_url" => "2001"})
    au.au_state = AuState.get(AuState::RETIRED);
    au.off_line = false; 
    assert !au.save
  end 
  
  def test_dont_save_bad_aus 
    col = collection("year param too", [{:name => "year", :kind => "string"}])
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"years" => "2001"})
    assert !au.save
    
    assert_raise RuntimeError do
      au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"" => "2001"})
    end 
    
    au = ArchivalUnit.new(:collection => col, 
                          :param_values => {"year" => ""})
    assert !au.save
  end
  
  def test_hashToStringToHash
    hash = { "base_url" => "http://some.com" }
    str = ArchivalUnit.hashToParamString(hash); 
    assert str.include?("base_url=http://some.com"); 
    hsh = ArchivalUnit.stringToParamHash(str); 
    assert hsh == hash 
    
    hash["year"] = "1989"; 
    str = ArchivalUnit.hashToParamString(hash); 
    assert str.include?("base_url=http://some.com"); 
    assert str.include?("year=1989"); 
    hsh = ArchivalUnit.stringToParamHash(str); 
    assert hsh == hash   
  end
  
  def test_badParamString
    assert_raise RuntimeError do
      ArchivalUnit.stringToParamHash("="); 
    end  
    assert_raise RuntimeError do
      ArchivalUnit.stringToParamHash("x="); 
    end 
    assert_raise RuntimeError do
      ArchivalUnit.stringToParamHash("=y"); 
    end 
    assert_raise RuntimeError do
      ArchivalUnit.stringToParamHash("x=y#{ArchivalUnit::PARAM_SPLIT}x=z"); 
    end 
    assert_raise RuntimeError do
      ArchivalUnit.stringToParamHash(ArchivalUnit::PARAM_SPLIT); 
    end   
    assert_raise RuntimeError do
      ArchivalUnit.stringToParamHash("kk#{ArchivalUnit::PARAM_SPLIT}vv=xx"); 
    end  
    assert_raise RuntimeError do
      ArchivalUnit.stringToParamHash("yy=zz#{ArchivalUnit::PARAM_SPLIT}hh"); 
    end  
  end
  
  def test_badParamHash
    assert_raise RuntimeError do
      ArchivalUnit.hashToParamString({ ArchivalUnit::PARAM_SPLIT => "t" }); 
    end
    assert_raise RuntimeError do
      ArchivalUnit.hashToParamString({ "jkahsk" => ArchivalUnit::PARAM_SPLIT }); 
    end
    assert_raise RuntimeError do
      ArchivalUnit.hashToParamString({ nil => "kjasl" }); 
    end
    assert_raise RuntimeError do
      ArchivalUnit.hashToParamString({ "" => "ksjdgh" }); 
    end
  end
end
