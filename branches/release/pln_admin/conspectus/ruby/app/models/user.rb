class User < ActiveRecord::Base
  belongs_to :content_provider 
  
  acts_as_authentic
  
  def self.super?(user) 
    if (user) then return user.super? else return false; end 
  end
  
   def self.edit?(user) 
    if (user) then return user.edit? else return false; end 
  end
  
  def self.obj_edit?(obj, user)
    return false if user.nil? || obj.nil?; 
    return true if user.rights == "super";
    begin 
      return user.rights == "edit" && obj.content_provider == user.content_provider
    rescue
      return false 
    end   
  end      
  
  def super?
    return rights == "super"; 
  end
  
  def edit? 
    return rights != "view"
  end
  
  def to_s
    return "#{login} #{rights} #{content_provider.acronym unless content_provider.nil?} #{email}";     
  end
  
  #  create/update users from "config/data/#{site}/users.yml" 
  def self.update(site)
    puts "--- #{self.name}.update";     
    load("config/data/#{site}/users.yml", false); 
  end
  
  
  #  create/update users from file 
  def self.load(file, reset_pwd) 
    list = YAML.load_file(file)
    list.each { |k,h| begin  
        cp = h["content_provider"];
        if (!cp.nil?) then 
          cp = ContentProvider.find_by_acronym(cp); 
        end
        if (cp.nil?) then 
           cp = ContentProvider.find(:first); 
        end 
        if (cp.nil?) then 
            raise "Must have content_provider to create user"; 
        end 
        h["content_provider"] = cp;
        #puts h.inspect; 
        
        inst = User.find_by_login(h['login']); 
        if (reset_pwd || inst.nil?) then 
          h["password_confirmation"] = h["password"]; 
        else 
          h.delete("password_confirmation"); 
          h.delete("password"); 
        end 
        if (inst.nil?) then 
          inst = u = User.new(h); 
        else 
          inst.update_attributes(h);   
        end
        inst.save!
        #puts "> #{inst}";
      rescue
        puts "Could not create/update User #{k}"
        $stderr.puts $!; 
      end 
    } 
  end
  
  def to_json(*a)
    {
      'login' => login,
      'first_name' => first_name,
      'last_name' => last_name,
      'email' => email,
      'content_provider' => content_provider.acronym,
      'rights' => rights
    }.to_json(*a)
  end

end
