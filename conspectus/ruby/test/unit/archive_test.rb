require File.dirname(__FILE__) + '/../test_helper'

class ArchiveTest < ActiveSupport::TestCase
  fixtures :archives

  # Replace this with your real tests.
  def test_unique_name
    a = archives(:arch1) 
    b = Archive.new(:title => "  #{a.title} ")
    assert !b.save
  end
  
  URL_PATTERN = "http:///xxx.org/<PLAUGIN>?base_url=<BASE_URL>&title=<TITEL>";

 
  def test_metada_handler
    arch = Archive.find(:first);
    arch.metadata_url_pattern(:create, URL_PATTERN);
    arch.metadata_url_pattern(:update, URL_PATTERN);
    arch.metadata_url_pattern(:show, URL_PATTERN);
    assert(arch.save); 
    assert_raise RuntimeError do 
       arch.metadata_url_pattern(:other, URL_PATTERN)
    end
  end

  def test_access_archive  
    obj = Archive.find(:first) 
    assert UserTestHelper.user_may_update(obj, "super") ==  true;
    assert UserTestHelper.user_may_update(obj, "one_edit") == false; 
    assert UserTestHelper.user_may_update(obj, "one_view") == false; 
  end
end
