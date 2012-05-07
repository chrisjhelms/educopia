#puts "rake_sepcific.rb" 

Opts::GLOBALS['RAKE_BUNDLES'] = Opts.new("rake_options", {})

Opts::GLOBALS['RAKE_BUNDLES']['PROD'] = 
            { 'LABEL' => 'prod', 
              'RAILS_ENV' => "ma_prod",
              'BACKUP_DIR' => "./db/dumps"}; 
Opts::GLOBALS['RAKE_BUNDLES']['TOY'] = 
            { 'LABEL' => 'toy', 
              'RAILS_ENV' => "ma_toy",
              'BACKUP_DIR' => "./db/dumps"}; 
                                     
