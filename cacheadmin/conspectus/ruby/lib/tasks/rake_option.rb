
require "lib/opts"; 

class RakeOption <  Opts

   attr_reader(:name);

   ALL_OPTS = {}; # Hash TaskName => RakeOption instances 

   DEFAULT_OPTS = {
         'DRY_RUN' => "false", 
         'RAILS_SILENT' => "false",
         'RAILS_ENV' => RAILS_ENV,
         'BUNDLE' => nil
   }

   # merge options from BUNDLE param with other options from command line 
   def initialize(name, hash)
      if (ENV.key?('BUNDLE')) 
        bundle = Opts::GLOBALS.fetch('RAKE_BUNDLES',{})[ENV['BUNDLE']];
        hash = hash.merge(Opts::GLOBALS.fetch('RAKE_BUNDLES',{})[ENV['BUNDLE']])
      end
      super(name, DEFAULT_OPTS.merge(hash))
      self.merge(ENV);
      ALL_OPTS[name] = self; 
   end

end