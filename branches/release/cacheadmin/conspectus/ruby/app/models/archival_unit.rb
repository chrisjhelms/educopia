class ArchivalUnit < ActiveRecord::Base
  include ActiveRecordExtension 
  
  PARAM_SPLIT = "_&_";
  
  belongs_to :collection;
  belongs_to :au_state;
  validates_presence_of :collection_id, :param_values, :au_state_id; 
  has_many(:preservation_status_items, 
           :order => :'cache ASC',
           :dependent => :destroy); 
  
  
  def initialize(opts = {}) 
    opts = {:au_state_id => AuState.get(AuState::DRAFT)}.merge(opts) 
    col =  opts[:collection]
    if (col.nil?) then 
      col  = Collection.find(opts[:collection_id]) 
    end
    if (col != nil) then 
      param_values = opts[:param_values] || {}; 
      opts[:param_values] = ArchivalUnit.param_str(col.base_url, param_values); 
    end  
    super(opts)
  end
  
  
  private 
  # generate string encoding of params (used in db to identify archival units) 
  # * base_url:   base_url value of this archival unit 
  # * extra_params: has with optional extra parameters used by archival unit 
  def self.param_str(base_url, extra_params)
     param_str = "base_url=#{base_url}"; 
     if (!extra_params.empty?) then  
        param_str = [param_str,  ArchivalUnit.hashToParamString(extra_params)].join(PARAM_SPLIT)
    end
    return param_str
 end
  
  public 
  # include values from other db tables in find
  def self.findincludes(*args)
      options = args.extract_options!
      options = {:include => [:au_state => [], :collection => [:plugin]  ]}.merge(options);
      find(args.first, options); 
  end 

  # find archival unit with defined by given parameters 
  # * plugin:  archival units plugin 
  # * baseurl: its base_url 
  # * extraparams: hash with addition parameters and their values -- may be {} 
  def self.find_by_plugin_base_url_params(plugin, baseurl, extraparams)
    return nil if plugin.nil?;
    return nil if baseurl.nil?;
    str = param_str(baseurl, extraparams);
    return find(:first, 
                 :include => { :collection => :plugin } , 
                 :conditions => { :archival_units => { :param_values => str}, 
                                  :collections => { :plugin_id => plugin.id}  } )

  end
  
  def content_provider 
    return collection.content_provider; 
  end
  
  def preservation_status_items_count 
     return PreservationStatusItem.count(:all, :conditions =>  { :archival_unit_id => self.id } ) 
  end

  def assume_super_user=(b)
    @assume_super_user = b;
  end
  
  def self.find_by_states(states) 
    aus = ArchivalUnit.findincludes(:all,  :conditions => find_by_states_sql(states) ); 
    return aus; 
  end
  
  def self.find_by_states_sql(states) 
    return match = states.collect{ |s| "( `au_state_id` = #{s.id} )" }.join(" OR ")
  end
  
  # param with_super_power indicates whether regular user or super user calls this method 
  # regular users may only delete if au is not in an iireversible state 
  # power user may delete only if au has  no preservation status items 
  def deletable?(with_super_power = false)
     if (with_super_power) then 
        return preservation_status_items_count == 0; 
     end 
     return !au_state.irreversible?
  end
  
  def inspect 
    return  "<#{self.class.name} id:#{id} collection_id: #{collection_id} param_values: #{param_values} au_state: #{au_state.name}>"; 
  end
  
  #  can't destroy if plugins exist that refer to this content provider
  def destroy 
    raise "#{self.inspect}: can't destroy" if !deletable?(@assume_super_user)
    ArchivalUnit.delete(self.id)
  end
  
  # return number of replication   
  def rep_count 
    a = self; 
    atts = a.instance_variable_get("@attributes"); 
    if (val = atts["rep_count"]) then 
      return val;
    end
    n = PreservationStatusItem.count(:all, :conditions => { :archival_unit_id => self.id } )
    atts = atts.merge( "rep_count" => n ); 
    a.instance_variable_set("@attributes", atts); 
    return n;
  end
  
  # return true/false if it archival unit has preservation status information  
  def has_status? 
    return 0 != rep_count
  end
  
  # return collections plugin 
  def plugin 
    return collection.plugin; 
  end
  
  # return collections base_url 
  def base_url 
    return collection.base_url; 
  end
  
  def reset_signature(url) 
    raise "May not change archival unit signature" if au_state.irreversible? 
    hsh = ArchivalUnit.stringToParamHash(self.param_values); 
    if (hsh['base_url'] != url) then 
      hsh['base_url'] = url;
      self.param_values = ArchivalUnit.hashToParamString(hsh); 
      self.lockss_au_id = nil;
    end
  end
  
  # retire or unretire according to ret param and save
  # skip validations if val = false  
  # raise exception if an save is not succesfull 
  def retire!(ret, val = true) 
    self.au_state = AuState.getRetired(); 
    save!(val);
  end
  
  def retired?() 
    return au_state == AuState.get(AuState::RETIRED); 
  end
  
  # set offline according to off param save
  # save! 
  def offline!(off) 
    self.off_line = off; 
    save!
  end
  
  # return param_names list without base_url
  def au_param_names(check = true)
    lst = collection.plugin.param_names; 
    lst.delete("base_url"); 
    return lst; 
  end
  
  # return param_value hash without base_url value 
  def au_param_values(check = true)
    hsh = ArchivalUnit.stringToParamHash(param_values, check)
    hsh.delete("base_url"); 
    return hsh; 
  end

  
  protected
  # convert param_values hash to string
  def self.hashToParamString(param_values) 
     pvs = []; 
     param_values.keys.sort.each { |k| 
        v = param_values[k]; 
        if (k.nil? || k == "") then
          raise "empty parameter name '#{k}' => '#{v}'"
        end
        # remove leading and trailing blanks 
        v = v.sub(/^ */, '').sub(/ *$/, '') 
        param =  "#{k}=#{v}"
        if (param.include?(PARAM_SPLIT)) then 
             raise "malformed parameter name '#{k}' => '#{v}' contains #{PARAM_SPLIT}"
        end
        pvs <<  "#{k}=#{v}"
     }
     return pvs.join(PARAM_SPLIT); 
  end
  
  # convert parameter string to hash 
  def self.stringToParamHash(param_string, check= true)
     hsh = {}; 
     last_key = nil;
     param_string.split(PARAM_SPLIT).each { |s| 
              p = s.split('=', 2); 
              if (check) then 
                if (p[0].nil? || p[0] == "") then  
                  raise "malformed parameter string '#{param_string}' contains empty name"
                end
                if (p[1].nil? || p[1] == "") then 
                  raise "malformed parameter string '#{param_string}' contains empty value"
                end
                if (p[0] == last_key) then 
                  raise "malformed parameter string '#{param_string}' contains #{p[0]} twice"
                end
              end
              hsh[p[0]] = p[1];
              last_key = p[0];
     } 
     if (hsh.empty?) then 
                raise "malformed parameter string '#{param_string}'"
     end
     return hsh; 
  end

  # assume validation not done by super_user 
  def validate
    #puts "#{self.class.name}.validate";
    if (errors.empty?) then  
      if (collection.new_record?) then 
        errors.add_to_base("Can't attach to unsaved collection #{collection.name}" )
      end
      if (collection.retired?) then 
        if (!au_state.retired?) then 
          errors.add_to_base "Can only assume retired state since it is part of retired collection"; 
          return;
        end
      end
      # make sure its 
      #     offline only if irreversible and not testing
      # make sure all retired aus are offline 
      if (off_line) then 
        if (au_state.test?) then 
         errors.add_to_base "Can't be offline and in testing" 
        elsif !au_state.irreversible? then
          errors.add_to_base "Can't be offline and not yet preserved" 
        end
      else
        if (au_state.retired?) then 
          errors.add_to_base "Retired archival units must be offline" 
        end 
      end 
      begin 
        param_hash = ArchivalUnit.stringToParamHash(param_values);
        #check whether base_url param matches collection base_url 
        if collection.base_url != param_hash["base_url"] then 
          errors.add_to_base("base_url values does not match with base_url of collection '#{collection.title}'")
          return; 
        end 
        # check whether parameters match plugin definition 
        errs = collection.plugin.param_values_match?(param_hash)
        if (!errs.empty?) then 
          errs.each {|e| 
            errors.add_to_base(e)
          }
          return; 
        end 
        # check whether we already have au with same param setting and same plugin 
        aus = ArchivalUnit.find(:all, :conditions => {:param_values => param_values}); 
        if (!aus.nil?) then
          same = aus.select  { |au| au.collection.plugin == plugin }
          if (!same.empty?) then 
            same = same[0];
            if (same.id != self.id) then 
              errors.add_to_base("Archival Unit with same parameters exists in #{same.collection.title}")
            elsif (!same.au_state.allow_transition_to(self.au_state, @assume_super_user) ) then 
              errors.add_to_base("Can not change state #{same.au_state.name} to #{self.au_state.name}"); 
            end
          end
        end
        
      rescue RuntimeError
        errors.add_to_base($!)
        return;
      end 
    end
  end
  
public
 def toTxt() 
   return "/archival_units/#{id} in '#{collection.title}' by CP:#{content_provider.acronym}"
 end
 
 def self.to_xml(options={})
       options[:indent] ||= 2
       options[:au_list] ||= []
       aus = options[:au_list]
       xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
       xml.instruct! unless options.delete(:skip_instruct)     
       xml.property(:name =>  "title") do 
            aus.each do  |au| 
              au.to_xml(options.merge(:builder => xml, :skip_instruct => true))
           end
       end 
 end
 
 def self.to_csv(options={})
       options[:separator] ||= '\t';
       options[:au_list] ||= []
       aus = options[:au_list]
       sep = options[:separator]
       str = ""
       aus.each do  |au| 
          str +=  "#{au.collection.title}#{sep}"  + 
               "#{au.collection.plugin.name}#{sep}" +
               "#{au.collection.base_url}#{sep}" +               
               "#{au.param_values}\n";
       end 
       return str;
 end
 
 def to_xml(options={}) 
       options[:indent] ||= 2
       xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
       coll = options[:collection] ||= collection;  
       
       
       xml.instruct! unless options.delete(:skip_instruct)     
       title = "#{coll.content_provider.acronym}: #{coll.title}";
       jtitle =  title;
       if (!au_param_values.empty?) then 
          pvals = au_param_values.collect{|k,v| "#{k}=#{v}" }.join(",");
          pvals = pvals.gsub(/[^a-zA-Z0-9:=-_,\/]/, '_') 
          title = "#{title}: #{pvals}"; 
       end 
       xml.property(:name =>  title) do 
            xml.property(:name => 'title', :value => title)
            xml.property(:name => 'journalTitle', :value => jtitle)
            xml.property(:name => 'plugin', :value => coll.plugin.name)
          
            xml.property(:name => "param.1") do 
                xml.property(:name => "key", :value => "base_url"); 
                xml.property(:name => "value", :value => coll.base_url); 
            end
            i = 2; 
           
            au_param_values(false).each do |key, value| 
              xml.property(:name => "param.#{i}") do 
                xml.property(:name => "key", :value => key); 
                xml.property(:name => "value", :value => value); 
              end
              i = i + 1
            end 
            if (off_line) then 
            xml.property(:name => "param.#{111 * i}") do 
                xml.property(:name => "key", :value => 'pub_down'); 
                xml.property(:name => "value", :value => "true"); 
            end  
            end
            xml.property(:name => "attributes.publisher", :value => coll.plugin.content_provider.name) 
       end
  end

  def as_json(opts = {})
    extra = self.to_hash()
    extra.delete('au_state_id')
    extra.delete('param_values')
    extra['params'] = ArchivalUnit.stringToParamHash(param_values)
    extra['au_state_name'] = au_state.name
    return extra
  end
  
end
