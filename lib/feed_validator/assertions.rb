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

require 'feed_validator'
require 'test/unit'
require 'tmpdir'
require 'md5'

module W3C
  class FeedValidator
    # Parse a response from the w3c feed validation service.
    # Used by assert_valid_feed
    def parse(response)
      clear
      if response.respond_to?(:body)
        parse_response(response.body)
      else
        parse_response(response)
      end      
    end
  end
end

class Test::Unit::TestCase

  # Assert that feed is valid according the {W3C Feed Validation online service}[http://validator.w3.org/feed/].
  # By default, it validates the contents of @response.body, which is set after calling
  # one of the get/post/etc helper methods in rails. You can also pass it a string to be validated.
  # Validation errors, warnings and informations, if any, will be included in the output. The response from the validator
  # service will be cached in the system temp directory to minimize duplicate calls.
  #
  # For example in Rails, if you have a FooController with an action Bar, put this in foo_controller_test.rb:
  #
  #   def test_bar_valid_feed
  #     get :bar
  #     assert_valid_feed
  #   end
  #
  def assert_valid_feed(fragment=@response.body)
    v = W3C::FeedValidator.new()
    filename = File.join Dir::tmpdir, 'feed.' + MD5.md5(fragment).to_s
    begin
      response = File.open filename do |f| Marshal.load(f) end
      v.parse(response)
  	rescue   
      unless v.validate_data(fragment)
        warn("Sorry! could not validate the feed.")
        return assert(true,'')
      end
      File.open filename, 'w+' do |f| Marshal.dump v.response, f end
  	end
    assert(v.valid?, v.valid? ? '' : v.to_s)
  end
  
  # Class-level method to quickly create validation tests for a bunch of actions at once in Rails.
  # For example, if you have a FooController with three actions, just add one line to foo_controller_test.rb:
  #
  #   assert_valid_feed :bar, :baz, :qux
  #
  def self.assert_valid_feed(*actions)
    actions.each do |action|
      class_eval <<-EOF
        def test_#{action}_valid_feed
          get :#{action}
          assert_valid_feed
        end
      EOF
    end
  end
  
end