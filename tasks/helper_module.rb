#!/usr/bin/env ruby
module myhelper
  BITLY_LOGIN = "plotti"
  BITLY_API_KEY = "R_fb1f65003bba56b566ed65be4a773741"
  
  def alnorm(x, upper = true)
    # Local variables
    con = 1.28 ; fn_val = 0.0
  
    # Machine dependent constants
    # I arbitrarily left them untouched -- refer to the paper for more information
    ltone = 7.0 ; utzero = 18.66
  
    p = 0.398942280444 ; q = 0.39990348504 ; r = 0.398942280385
    a1 = 5.75885480458 ; a2 = 2.62433121679 ; a3 = 5.92885724438
    b1 = -29.8213557807 ; b2 = 48.6959930692
    c1 = -3.8052E-8 ; c2 = 3.98064794E-4 ; c3 = -0.151679116635 ; c4 = 4.8385912808 ; c5 = 0.742380924027 ; c6 = 3.99019417011
    d1 = 1.00000615302 ; d2 = 1.98615381364 ; d3 = 5.29330324926 ; d4 = -15.1508972451 ; d5 = 30.789933034
  
    up = upper
    z = x
    if z < 0.0
       up = !up
       z = -z
    end
    if (z <= ltone or (up and z <= utzero))
       y = 0.5*z*z
       if (z > con)
          fn_val = r*Math.exp(-y)/(z+c1+d1/(z+c2+d2/(z+c3+d3/(z+c4+d4/(z+c5+d5/(z+c6))))))
       else
          fn_val = 0.5 - z*(p-q*y/(y+a1+b1/(y+a2+b2/(y+a3))))
       end
    else
       fn_val = 0.0
    end
  
    if (!up) ; fn_val = 1.0 - fn_val ; end
  
    fn_val
  end
  
  
  def self.get_urls (text)
    a = text.gsub(/((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/).to_a   
  end
  
  def self.get_expanded_urls (text)
    results = []
    if get_urls(text) != []    
      get_urls(text).each do |url|     
        if URI.parse(url).host == "bit.ly"
          begin
            tmp_res = self.expand_url(:params => {:shortUrl => url})
          rescue
          end
          if tmp_res != nil
            temp = tmp_res["results"]
            errorcode = tmp_res["statusCode"]          
            if errorcode != "ERROR"
              if temp != nil                 
                key = temp.keys.first
                results << temp[key]["longUrl"]
              end
            end
          end        
      else
        results << url
        end
      end      
    end
    return results
  end
end