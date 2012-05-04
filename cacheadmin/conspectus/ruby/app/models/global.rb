class Global < ActiveRecord::Base
    
  private
  @@cache = {};

  
  def self.set(name, value)
    g = Global.find_by_name(name);
    if (value == "") then value = nil; end 
    if (g.nil?) then
      g = Global.new(:name => name, :value => value)
    else
      g.value = value;
    end
    g.save!
  end

  public

  def self.get(name)
    if (!@@cache[name])  then
      g =  self.find_by_name(name);
      if (!g.nil? && g != "") then
        @@cache[name] = g.value
      end
    end
    return @@cache[name]
  end

  def self.premis_url
      url = Global.get("premis_url");
      return nil if (url.nil? || url.empty?); 
      return url; 
  end
  
  def self.status_url
      url = Global.get("status_url");
      return nil if (url.nil? || url.empty?); 
      return url; 
  end
  
  def self.plugin_url(mode)
      url = Global.get("#{mode}_plugin_url");
      return nil if (url.nil? || url.empty?); 
      return url; 
  end
  
  def self.plugin_urls
      list = self.find(:all, :conditions => "name LIKE '%plugin_url'" )
  end
  
 
  def self.update(site = nil)
    puts "--- #{self.name}.update";
    @@cache = {};
    if (!site.nil?) then
      vals = YAML.load_file("config/data/#{site}/globals.yml")
      vals.each { |k,h|
        g = Global.set(h["name"], h["value"]);
        puts "> set #{h["name"]} #{h['value']}";  }
    end

    set("app_title", "Conspectus") unless get("app_title");
    set("support", "<a href='mailto:support@metaarchive.org?subject=conspectus'> support@metaarchive.org </a>") unless get("support");
    set("data_source", "Production Data for PLN") unless get("data_source");
    set("show_params", "") unless get("show_params");
    set("skin_css", "default") unless get("skin_css");
    set("test_plugin_url", "") unless get("test_plugin_url");
    set("production_plugin_url", "") unless get("production_plugin_url");
    set("retired_plugin_url", "") unless get("retired_plugin_url");
    set("status_monitor", "") unless get("status_monitor");
  end
end
