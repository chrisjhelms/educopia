

module  ActiveRecordExtension
  ActiveRecord::Base.include_root_in_json = false;

  def ActiveRecordExtension.compact_string(str)
    if !str.nil? then  
      str = str.chomp.gsub(/\s+/, ' ')
      str = str.gsub(/^\s/, '')
      str = str.gsub(/\s$/, '')
    end
    return str;
  end
  
  attr_reader :allowed_actions
  attr_writer :allowed_actions

  def to_hash
    hash = {}; self.attributes.each { |k,v| hash[k] = v } 
    hash.delete('created_at')
    hash.delete('updated_at')
    return hash
  end

  def save!(val = true) 
    rc = save(val); 
    if (!rc) then 
       errs =  errors.to_enum.collect { |e|  (e[0] == "base") ? e[1] : (e[0] + ": " + e[1])  }.join("\n");
       raise errs; 
    end
    return rc;
  end
  
  def as_json(opts = {})
    return super.as_json(opts.merge(:except => ['updated_at', 'created_at']))
  end
  
  def compact_string(str) 
    ActiveRecordExtension.compact_string(str)
  end
  
  def self.per_page
    20
  end
 
  
  # check whether user may perform action on given object
  # super users may do anything 
  # users with same content_provider as object and edit rights may update, and delete 
  # users != nil  may create  
  # params: 
  # user may be nil  
  # action is :create, :read, :update :delete 
  def check_rights(user, action) 
    return true if !user.nil && user.super?; 
    if (action == :read) then 
      return true; 
    elsif (action == :update || action == :delete) then 
      me_cp = nil; 
      begin 
        me_cp = self.content_provider;
      rescue
        # self has no content_provider will not allow editing 
        return false; 
      end 
      return user.content_provider == me_cp && user.rights == "edit"; 
    end
    return false; 
  end

end














