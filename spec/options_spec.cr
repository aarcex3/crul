require "./spec_helper"
require "uri"

describe Crul::Options do
  describe ".parse" do
    it "uses defaults" do
      options = Crul::Options.parse(args: "http://example.org".split(" "))

      options.method.should eq(Crul::Methods::GET)
      options.url.should be_a(URI)
      options.url.to_s.should eq("http://example.org")
      options.format.should eq(Crul::Formats::Auto)
    end

    it "parses GET with JSON" do
      options = Crul::Options.parse(args: "GET http://example.org -j".split(" "))

      options.method.should eq(Crul::Methods::GET)
      options.url.should be_a(URI)
      options.url.to_s.should eq("http://example.org")
      options.format.should eq(Crul::Formats::JSON)
      options.basic_auth.should eq(nil)
      options.cookie_store.filename.should eq(nil)
    end

    it "parses POST with JSON" do
      options = Crul::Options.parse(args: "POST http://example.org -j".split(" "))

      options.method.should eq(Crul::Methods::POST)
      options.url.should be_a(URI)
      options.url.to_s.should eq("http://example.org")
      options.format.should eq(Crul::Formats::JSON)
    end

    it "parses GET with XML" do
      options = Crul::Options.parse(args: "GET http://example.org -x".split(" "))

      options.method.should eq(Crul::Methods::GET)
      options.url.should be_a(URI)
      options.url.to_s.should eq("http://example.org")
      options.format.should eq(Crul::Formats::XML)
    end

    it "parses GET with plain" do
      options = Crul::Options.parse(args: "GET http://example.org -p".split(" "))

      options.method.should eq(Crul::Methods::GET)
      options.url.should be_a(URI)
      options.url.to_s.should eq("http://example.org")
      options.format.should eq(Crul::Formats::Plain)
    end

    it "parses without protocol" do
      options = Crul::Options.parse(args: "example.org".split(" "))

      options.url.should be_a(URI)
      options.url.to_s.should eq("http://example.org")
    end

    it "accepts a request body" do
      options = Crul::Options.parse(args: "http://example.org -d data".split(" "))
      options.body.should eq("data")
    end

    it "accepts a request body as a file" do
      options = Crul::Options.parse(args: "http://example.org -d @./spec/data/test.txt".split(" "))

      options.errors.empty?.should be_true
      options.body.should eq("This is a test file")
    end

    it "manages a file not found" do
      options = Crul::Options.parse(args: "http://example.org -d @wadus.txt".split(" "))

      options.errors.empty?.should_not be_true
      options.body.should be_nil
    end

    it "accepts headers" do
      options = Crul::Options.parse(args: "http://example.org -H header1:value1 -H header2:value2".split(" "))

      options.headers["Header1"].should eq("value1")
      options.headers["Header2"].should eq("value2")
    end

    it "accepts headers with JSON values" do
      header_value = {"a" => "b"}
      options = Crul::Options.parse(args: "http://example.org -H JSON:#{header_value.to_json}".split(" "))

      Hash(String, String).from_json(options.headers["json"]).should eq(header_value)
    end

    it "gets user and password with --auth" do
      options = Crul::Options.parse(args: "GET http://example.org --auth foo:bar".split(" "))
      options.basic_auth.should eq({"foo", "bar"})
    end

    it "gets user and password with -a" do
      options = Crul::Options.parse(args: "GET http://example.org -a foo:bar".split(" "))
      options.basic_auth.should eq({"foo", "bar"})
    end

    it "reads and writes cookies from file" do
      options = Crul::Options.parse(args: "GET http://example.org -c /tmp/cookies.json".split(" "))
      options.cookie_store.should be_a(Crul::CookieStore)
      options.cookie_store.filename.should eq("/tmp/cookies.json")
    end

    it "handles query data" do
      options = Crul::Options.parse(args: "GET http://example.org?a=1&b=2".split(" "))
      options.url.query_params.should eq(URI::Params{"a" => ["1"], "b" => ["2"]})
    end
  end
end
