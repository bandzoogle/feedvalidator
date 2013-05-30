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
require 'feed_validator'

class FeedValidatorTest < Test::Unit::TestCase
  
  def test_validate_url
    v = W3C::FeedValidator.new()
    assert v.validate_url('http://www.w3.org/QA/news.rss')
    if v.valid?
      assert v.errors.size == 0
    else
      assert v.errors.size > 0
    end
  end

  def test_validate_data
    v = W3C::FeedValidator.new()
    
    data = ""
    File.open(File.dirname(__FILE__) + "/../feeds/" + "weblog.rubyonrails.org_rss_2_0_articles.xml").each { |line|
      data << line
    }
    assert v.validate_data(data)
    assert !v.valid?
    assert v.errors.size > 0
    assert v.warnings.size == 0
    assert v.informations.size == 0

    data = ""
    File.open(File.dirname(__FILE__) + "/../feeds/" + "www.w3.org_news.rss.xml").each { |line|
      data << line
    }
    assert v.validate_data(data)
    assert v.valid?
    assert v.errors.size == 0
    assert v.warnings.size >= 1
    
    data = ""
    File.open(File.dirname(__FILE__) + "/../feeds/" + "weblog.rubyonrails.org_rss_2_0_articles_malformed.xml").each { |line|
      data << line
    }
    assert v.validate_data(data)
    assert !v.valid?
    assert v.errors.size == 1
    assert v.errors.first[:line] == "5"
    assert v.errors.first[:column] == "4"
  end
  
end