#--
# Copyright (c) 2006 Edgar Gonzalez <edgar@lacaraoscura.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
#
# Provide an interface to the {W3C Feed Validation online service}[http://validator.w3.org/feed/], 
# based on its SOAP 1.2 support. 
#
require 'net/http'
require 'cgi'
require 'rexml/document'

module W3C

  # Implements an interface to the {W3C Feed Validation online service}[http://validator.w3.org/feed/], 
  # based on its SOAP 1.2 support. 
  #
  # It helps to find errors in RSS or Atom feeds.
  # ---
  # Please remember that the {W3C Feed Validation service}[http://validator.w3.org/feed/] is a shared resource,
  # so do not abuse it: you should make your scripts sleep between requests.
  #
  class FeedValidator
    VERSION = "0.1.1"

    # True if the w3c feed validation service not found errors in the feed.
    #
    attr_reader :valid
    
    # The complete response (as Net::HTTPResponse object) sent it by the w3c feed validation service.
    #
    attr_reader :response
    
    # Collection of _errors_ founded by the w3c feed validation service.
    # Every error is a hash containing: <tt>:type</tt>, <tt>:line</tt>, 
    # <tt>:column</tt>, <tt>:text</tt>, <tt>:element</tt>
    #
    attr_reader :errors

    # Collection of _warnings_ founded by the w3c feed validation service.
    # Every error is a hash containing: <tt>:type</tt>, <tt>:line</tt>, 
    # <tt>:column</tt>, <tt>:text</tt>, <tt>:element</tt>
    #
    attr_reader :warnings

    # Collection of _informations_ founded by the w3c feed validation service.
    # Every error is a hash containing: <tt>:type</tt>, <tt>:line</tt>, 
    # <tt>:column</tt>, <tt>:text</tt>, <tt>:element</tt>
    #
    attr_reader :informations
  
    # Initialize the feed validator object
    #
    def initialize
      clear
    end
    
    # Validate the data provided. 
    # Returns a true value if the validation succeeded (regardless of whether the feed contains errors).
    #
    def validate_data(rawdata)
      clear
      params = "rawdata=#{CGI.escape(rawdata)}&manual=1&output=soap12"
      begin
        headers = ::VERSION == "1.8.4" ? {'Content-Type'=>'application/x-www-form-urlencoded'} : {}
        @response = Net::HTTP.start('validator.w3.org',80) {|http|
          http.post('/feed/check.cgi',params,headers)
        } 
      rescue Exception => e
        warn "Exception: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}" if $VERBOSE
        return false
      end
      parse_response(@response.body)
      return true
    end

    # Validate the url provided. 
    # Returns a true value if the validation succeeded (regardless of whether the feed contains errors).
    #
    def validate_url(url)
      clear
      params = "url=#{CGI.escape(url)}&output=soap12"
      begin
        @response = Net::HTTP.get_response('validator.w3.org',"/feed/check.cgi?#{params}",80)
      rescue Exception => e
        warn "Exception: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}" if $VERBOSE
        return false
      end
      parse_response(@response.body)
      return true
    end

    alias :valid? :valid

    def to_s
      msg = "Vailidity: #{@valid}\n"
      msg << "Errors count: #{@errors.size}\n"
      @errors.each_with_index{ |item, i| msg << "(#{i+1}) type: #{item[:type]} | line: #{item[:line]} | column: #{item[:column]} | text: #{item[:text]},\n"}  
      msg << "Warnings count: #{@warnings.size}\n"
      @warnings.each_with_index{ |item, i| msg << "(#{i+1}) type: #{item[:type]} | line: #{item[:line]} | column: #{item[:column]} | text: #{item[:text]},\n"}  
      msg << "Informations count: #{@informations.size}\n"
      @informations.each_with_index{ |item, i| msg << "(#{i+1}) type: #{item[:type]} | line: #{item[:line]} | column: #{item[:column]} | text: #{item[:text]},\n"}  
      msg
    end

    private
    
    def parse_response(response) #nodoc
      xml = REXML::Document.new(response)
      @valid = (/true/.match(xml.root.elements["env:Body/m:feedvalidationresponse/m:validity"].get_text.value))? true : false
      unless @valid
        xml.elements.each("env:Envelope/env:Body/m:feedvalidationresponse/m:errors/m:errorlist/error") do |error|
          @errors << {
            :type =>    error.elements["type"].nil? ? "" : error.elements["type"].get_text.value,
            :line =>    error.elements["line"].nil? ? "" : error.elements["line"].get_text.value,
            :column =>  error.elements["column"].nil? ? "" : error.elements["column"].get_text.value,
            :text =>    error.elements["text"].nil? ? "" : error.elements["text"].get_text.value,
            :element => error.elements["element"].nil? ? "" : error.elements["element"].get_text.value
            }
        end
      end
      xml.elements.each("env:Envelope/env:Body/m:feedvalidationresponse/m:warnings/m:warninglist/warning") do |warning|
        @warnings << {
          :type =>    warning.elements["type"].nil? ? "" : warning.elements["type"].get_text.value,
          :line =>    warning.elements["line"].nil? ? "" : warning.elements["line"].get_text.value,
          :column =>  warning.elements["column"].nil? ? "" : warning.elements["column"].get_text.value,
          :text =>    warning.elements["text"].nil? ? "" : warning.elements["text"].get_text.value,
          :element => warning.elements["element"].nil? ? "" : warning.elements["element"].get_text.value
          }
      end
      xml.elements.each("env:Envelope/env:Body/m:feedvalidationresponse/m:informations/m:infolist/information") do |info|
        @informations << {
          :type =>    info.elements["type"].nil? ? "" : info.elements["type"].get_text.value,
          :line =>    info.elements["line"].nil? ? "" : info.elements["line"].get_text.value,
          :column =>  info.elements["column"].nil? ? "" : info.elements["column"].get_text.value,
          :text =>    info.elements["text"].nil? ? "" : info.elements["text"].get_text.value,
          :element => info.elements["element"].nil? ? "" : info.elements["element"].get_text.value
          }
      end
    end

    def clear #nodoc
      @response = nil
      @valid = false
      @errors = []
      @warnings = []
      @informations = []
    end
      
  end
end