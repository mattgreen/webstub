WebStub [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mattgreen/webstub)
======

What if [WebMock](https://github.com/bblimke/webmock) and [NSURLProtocol](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURLProtocol_Class/Reference/Reference.html) had a baby?

Features
------------
* Supports most any HTTP library that is built on NSURLConnection
* Request matching based upon HTTP method, URI, and body
* Optionally, disable real network access
* Familiar, delicious syntax
* Bacon integration

Installation
------------
Please ensure you have the latest version of RubyMotion: (**WebStub requres version 1.24 or higher**)

    $ sudo motion update

Also, if you haven't done so already, please [configure](http://thunderboltlabs.com/posts/using-bundler-with-rubymotion) your project to use Bundler.

Update your Gemfile:

    gem "webstub", "~> 0.3.0"

Bundle:

    $ bundle install

Usage
-----
* Add the following line to the top-most `describe` block in your spec:

    `extend WebStub::SpecHelpers`

* Use the following methods to control the use of request stubbing:
  - `disable_network_access!`
  - `enable_network_access!`
  - `stub_request`
  - `reset_stubs`

Example Spec
------------

```ruby
describe "Example" do
  extend WebStub::SpecHelpers

  describe "Stubbing a GET request to return a simple response" do
    it "retrieves the front page" do
      stub_request(:get, "http://example.com/").
        to_return(body: "Hello!", content_type: "text/plain")

      @body = nil
      @api.get_index do |body, error|
        @body = body
        resume
      end

      wait_max 1.0 do
        @body.should.be == "Hello!"
      end
    end
  end

  describe "Stubbing a GET request to return JSON" do
    it "retrieves suggestions" do
      stub_request(:get, "https://example.com/suggestions?q=mu").
        to_return(json: { suggestions: ["muse"] })

      @suggestions = nil
      @api.get_suggestions("mu") do |results, error|
        @suggestions = results
        resume
      end

      wait_max 1.0 do
        @suggestions.should.not.be.empty
      end
    end
  end

  describe "Stubbing a POST request to return JSON" do
    it "handles a POST request" do
      stub_request(:post, "https://example.com/action").
        with(body: { q: "unsustainable" }).
        to_return(json: [ { album: "The 2nd Law", release_date: "2012-10-01", artist: "Muse" } ])

      @results = nil
      @api.get_album_info_for_track("unsustainable") do |results, error|
        @results = results
        resume
      end

      wait_max 1.0 do
        @results.should.not.be.empty
      end
    end
  end
end
```

Conventions
-----------------
- The URL is matched *exactly* as is right now (hence query parameters need to be included and encoded)
- The `with` method's `body` option accepts either a Hash or a String:
  - Hashes are assumed to be form data (with a `application/x-www-form-urlencoded` content type)
  - Strings are matched as is
- The `to_return` method accepts a few options:
  - `json`: accepts either a Hash, Array or a String. If a Hash or Array is provided, it will be converted to JSON. Strings are returned as is, with the Content-Type set to `application/json`.
  - `body`: accepts a String, and returns it as-is
  - `content_type`: sets the Content-Type when using the `body` parameter
  - `status_code`: sets the integer Status Code of the response. Defaults to `200`.

TODO
---------
* Handle query params similarly to form data
* URI canonicalization

