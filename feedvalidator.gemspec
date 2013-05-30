# Describe your gem and declare its dependencies:
$:.push File.expand_path("../lib", __FILE__)
require "feed_validator"

Gem::Specification.new do |s|
  s.name = "feedvalidator"
  s.version = W3C::FeedValidator::VERSION
  s.description = %q{Interface to the W3C Feed Validation online service http://validator.w3.org/feed/, based on its SOAP 1.2 support. It helps to find errors in RSS or Atom feeds. Add a new assertion to validate feeds against the W3C from within Rails functional tests}
  s.summary = %q{Interface to the W3C Feed Validation online service http://validator.w3.org/feed/}
  s.email = %q{colin@bandzoogle.com}
  s.authors = ["People"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency(%q<rake>, [">= 0"])
end
