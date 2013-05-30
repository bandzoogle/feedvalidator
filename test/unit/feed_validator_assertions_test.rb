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
$:.unshift(File.dirname(__FILE__) + "/../../lib/")

require 'test/unit'
require 'feed_validator/assertions'

class FeedValidatorAssertionsTest < Test::Unit::TestCase
  
  def test_assert_valid_feed
    # a valid feed
    data = ""
    File.open(File.dirname(__FILE__) + "/../feeds/" + "www.w3.org_news.rss.xml").each { |line|
      data << line
    }
    assert_valid_feed(data)
  end
  
  def test_cache
    # testing the cache using an invalid feed with a success response cached
    fragment_feed = ">--invalid feed--<"    
    response = File.open File.dirname(__FILE__) + "/../responses/success_with_warnings" do |f| Marshal.load(f) end
    filename = File.join Dir::tmpdir, 'feed.' + MD5.md5(fragment_feed).to_s
    File.open filename, 'w+' do |f| Marshal.dump response, f end
    assert_valid_feed(fragment_feed)  
  end
  
end