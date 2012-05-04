
class NetData
  attr_reader :result 
  
  # TODO setup such that rake tasks can define logger for STDOUT 
  def log(str)
    logger.info(str) if defined?(logger)
  end
  
  # initialize by issuing a request to given url
  # * url: obvious 
  # * method: "get" or "post" 
  # * args: arguments to be posted to post_form or to be appended to url 
  def initialize(url, method, request_args = {}, logger = nil)
    method = method.downcase
    @exception = nil   #exception triggerd by last method  
    @result =  nil     #result of get request to given url 
    @format = ""; 
    @url = url
    
    begin
      prt_args = "";

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = (method == "get") ? Net::HTTP::Get.new(uri.path) : Net::HTTP::Post.new(uri.path) 
      if (!request_args.empty?) then 
        request.set_form_data( request_args)
        prt_args = ((method == "get") ? "-G" : "") + " -d " + request.body
        if (method == "get") then 
          request = Net::HTTP::Get.new( uri.path + '?' + request.body ) 
        end
      end
      if (logger) then 
        logger.info( "HTTP #{method}: curl " + prt_args + " " + 
          uri.scheme + "://" + uri.host + ":" + String(uri.port) + 
          uri.request_uri)
      end
      
      @result= http.request(request)     
      @format = @result.content_type;
      if !(@result.is_a? Net::HTTPSuccess) then 
        raise "#{@result.class}";
      end
    rescue  Exception => e 
      log "#{self.class.name} failed to #{method} '#{url}' #{e}"
      @exception = e
    end
  end
 
  def body() 
    begin
      return nil if !(@result.is_a? Net::HTTPSuccess)
      return @result.body
    rescue Exception => e 
      return nil;
    end
  end
  
  def success 
    return @result.is_a? Net::HTTPSuccess
  end 
  
  def status 
    begin 
      return  Integer(@result.code)
    rescue
      return -1;  # bad url
    end  
  end 
   
  # TODO support conversion from XML 
  def convert(klass) 
    str = body()
    if (str.nil?) then 
      return nil;
    else 
      if ("application/json" == @format) then 
        begin 
          json = JSON.parse(str)
          if (json.class == Array) then 
            all = []
            json.each { |j| all << klass.send('new', j) }
            return all
          else 
            return klass.send('new', json)
          end 
        rescue  Exception => e
          log "#{self.class.name}: could not convert '#{@url}' to '#{klass.name}"; 
          log "#{self.class.name}: #{e}"
          @exception = e
        end 
      else 
        raise "Unsupported format #{@result.content_type}" 
      end
    end
  end
  
end
