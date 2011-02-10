
require 'net/http'
require 'rubygems'
require 'xmlsimple'
require 'uri'
require 'json'


class AlchemyAPI

  class OutputMode
    XML = "xml";
    JSON = "json";
  end

  attr_accessor :apiKey
  attr_accessor :hostPrefix

  def initialize()
    @apiKey
    @hostPrefix = "access"
  end

  def setAPIHost(host)
    @hostPrefix = host
    if (@hostPrefix.length < 2)
       raise "Error setting API host."
    end
  rescue => err
    raise "Error setting API host: #{err}"
  end

  def setAPIKey(key)
    @apiKey = key
    if (@apiKey.length < 5)
       raise "Error setting API key."
    end
  rescue => err
    raise "Error setting API key: #{err}"
  end

  def loadAPIKey(filename)
    @apiKey = ""
    file = File.new(filename, "r")
    if (line = file.gets)
	@apiKey = line.strip
    end
    file.close
    if (@apiKey.length < 5)
       raise "Error loading API key."
    end
  rescue => err
    raise "Error loading API key: #{err}"
  end

  def URLGetRankedNamedEntities(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetRankedNamedEntities", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def TextGetRankedNamedEntities(text, outputMode = OutputMode::XML)
    CheckText(text, outputMode)

    POST("TextGetRankedNamedEntities", "text", outputMode, { "text" => text });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetRankedNamedEntities(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetRankedNamedEntities", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetRankedKeywords(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetRankedKeywords", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def TextGetRankedKeywords(text, outputMode = OutputMode::XML)
    CheckText(text, outputMode)

    POST("TextGetRankedKeywords", "text", outputMode, { "text" => text });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetRankedKeywords(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetRankedKeywords", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetLanguage(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetLanguage", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def TextGetLanguage(text, outputMode = OutputMode::XML)
    CheckText(text, outputMode)

    POST("TextGetLanguage", "text", outputMode, { "text" => text });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetLanguage(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetLanguage", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetRawText(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetRawText", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetRawText(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetRawText", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetText(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetText", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetText(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetText", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetTitle(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetTitle", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetTitle(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetTitle", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetCategory(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetCategory", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetCategory(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetCategory", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def TextGetCategory(text, outputMode = OutputMode::XML)
    CheckText(text, outputMode)

    POST("TextGetCategory", "text", outputMode, { "text" => text });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetFeedLinks(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetFeedLinks", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetFeedLinks(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetFeedLinks", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetMicroformats(url, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    POST("URLGetMicroformatData", "url", outputMode, { "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetMicroformats(html, url, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)

    POST("HTMLGetMicroformatData", "html", outputMode, { "html" => html, "url" => url });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def URLGetConstraintQuery(url, query, outputMode = OutputMode::XML)
    CheckURL(url, outputMode)

    if (query.length < 2)
      raise "Invalid constraint query specified."
    end

    POST("URLGetConstraintQuery", "url", outputMode, { "url" => url, "cquery" => query });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def HTMLGetConstraintQuery(html, url, query, outputMode = OutputMode::XML)
    CheckHTML(html, url, outputMode)
    
    if (query.length < 2)
      raise "Invalid constraint query specified."
    end

    POST("HTMLGetConstraintQuery", "html", outputMode, { "html" => html, "url" => url, "cquery" => query });
  rescue => err
    raise "Error making API call: #{err}"
  end

  def CheckOutputMode(outputMode)
    if (@apiKey.length < 5)
       raise "Please load an API key."
    end
    if (OutputMode::XML != outputMode && OutputMode::JSON != outputMode)
      raise "Illegal Output Mode specified, see OutputMode class."
    end
  end

  def CheckURL(url, outputMode)
    CheckOutputMode(outputMode)
    if (url.length < 5)
      raise "Enter a valid URL to analyze."
    end
  end

  def CheckText(text, outputMode)
    CheckOutputMode(outputMode)
    if (text.length < 10)
      raise "Enter valid text to analyze."
    end
  end

  def CheckHTML(html, url, outputMode)
    CheckURL(url, outputMode)
    if (html.length < 10)
      raise "Enter a valid HTML document to analyze."
    end
  end

  def POST(endpoint, prefix, outputMode, args)
    httpDest = 'http://' + @hostPrefix + '.alchemyapi.com/calls/' + prefix + '/' + endpoint

    args['apikey'] = @apiKey
    args['outputMode'] = outputMode

    res = Net::HTTP.post_form(URI.parse(httpDest), args)


    if (OutputMode::XML == outputMode)
      data = XmlSimple.xml_in(res.body, { 'KeyAttr' => 'name' })
      if (data['status'].first.to_s != "OK")
        raise "#{data['statusInfo']}."
      end
    else
      data = JSON.parse(res.body)
      if (data['status'].first.to_s != "OK")
        raise "#{data['statusInfo']}."
      end
    end

    return res.body
  end
end
