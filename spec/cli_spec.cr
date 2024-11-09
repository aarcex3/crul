require "./spec_helper"

describe Crul::CLI do
  it "raises when no args" do
    expect_raises(ArgumentError) do
      lines = capture_lines do |output| # ameba:disable Lint/UselessAssign
        Crul::CLI.run!([] of String, output)
      end
    end
  end

  it "shows help" do
    lines = capture_lines do |output|
      Crul::CLI.run!(["-h"], output).should be_true
    end

    lines.first.should match(/\AUsage:/)
  end

  it "works with basic GET" do
    WebMock.stub(:get, "http://example.org/").to_return(body: "Hello", headers: {"Hello" => "World"})

    lines = capture_lines do |output|
      Crul::CLI.run!(["http://example.org"], output).should be_true
    end

    lines.first.should eq("HTTP/1.1 200 OK")
    lines.should contain("Hello: World")
    lines.last.should eq("Hello")
  end

  it "colorizes output" do
    WebMock.stub(:get, "http://example.org/").to_return(body: "Hello", headers: {"Hello" => "World"})

    lines = capture_lines(uncolorize?: false) do |output|
      Crul::CLI.run!(["http://example.org"], output).should be_true
    end

    lines.first.should eq("\e[94mHTTP/1.1\e[0m\e[36m 200 \e[0m\e[33mOK")
    lines.should contain("\e[0mHello: \e[36mWorld")
    lines.last.should eq("Hello")
  end

  it "works with GET with https" do
    WebMock.stub(:get, "https://example.org/").to_return(body: "Hello")

    lines = capture_lines do |output|
      Crul::CLI.run!(["https://example.org"], output).should be_true
    end

    lines.first.should eq("HTTP/1.1 200 OK")
    lines.last.should eq("Hello")
  end

  it "works with most basic GET without protocol (should default to http://)" do
    WebMock.stub(:get, "http://example.org/").to_return(body: "Hello")

    lines = capture_lines do |output|
      Crul::CLI.run!(["example.org"], output).should be_true
    end

    lines.first.should eq("HTTP/1.1 200 OK")
    lines.last.should eq("Hello")
  end

  it "works with most basic GET with port" do
    WebMock.stub(:get, "http://example.org:8080/").to_return(body: "Hello")

    lines = capture_lines do |output|
      Crul::CLI.run!(["http://example.org:8080/"], output).should be_true
    end

    lines.first.should eq("HTTP/1.1 200 OK")
    lines.last.should eq("Hello")
  end

  it "works with basic POST" do
    WebMock.stub(:post, "http://example.org/").to_return(body: "Hello")

    lines = capture_lines do |output|
      Crul::CLI.run!(["post", "http://example.org"], output).should be_true
    end

    lines.first.should eq("HTTP/1.1 200 OK")
    lines.last.should eq("Hello")
  end

  it "works with basic PUT" do
    WebMock.stub(:put, "http://example.org/").to_return(body: "Hello")

    lines = capture_lines do |output|
      Crul::CLI.run!(["put", "http://example.org"], output).should be_true
    end

    lines.first.should eq("HTTP/1.1 200 OK")
    lines.last.should eq("Hello")
  end

  it "works with basic DELETE" do
    WebMock.stub(:delete, "http://example.org/").to_return(body: "Hello")

    lines = capture_lines do |output|
      Crul::CLI.run!(["delete", "http://example.org"], output).should be_true
    end

    lines.first.should eq("HTTP/1.1 200 OK")
    lines.last.should eq("Hello")
  end
  describe "Integration" do
    describe "Basic auth" do
      it "sends the basic auth data" do
        WebMock.stub(:get, "http://example.org/auth")
          .with(headers: {"Authorization" => "Basic #{Base64.strict_encode("user:secret")}"})
          .to_return(body: "Hello, World")

        lines = capture_lines do |output|
          Crul::CLI.run!(["get", "http://example.org/auth", "-a", "user:secret"], output).should be_true
        end

        lines.first.should eq("HTTP/1.1 200 OK")
        lines.last.should eq("Hello, World")
      end
    end

    describe "Cookies" do
      it "stores and sends the cookies" do
        WebMock.stub(:get, "example.org/cookies/set")
          .to_return(headers: {"Set-Cookie" => "k1=v1; Path=/"}, body: "Cookie set")

        WebMock.stub(:get, "example.org/cookies/check")
          .with(headers: {"Cookie" => "k1=v1; Path=/"})
          .to_return(body: "Cookie received")

        lines = capture_lines do |output|
          Crul::CLI.run!(["get", "http://example.org/cookies/set", "-c", "/tmp/cookies"], output).should be_true
        end

        lines.first.should eq("HTTP/1.1 200 OK")
        lines.last.should eq("Cookie set")

        lines = capture_lines do |output|
          Crul::CLI.run!(["get", "http://example.org/cookies/check", "-c", "/tmp/cookies"], output).should be_true
        end

        lines.first.should eq("HTTP/1.1 200 OK")
        lines.last.should eq("Cookie received")
      end
    end

    describe "Sending data" do
      it "sends the data" do
        WebMock.stub(:post, "http://example.org/data")
          .with(body: "Hello")
          .to_return(body: "World")

        lines = capture_lines do |output|
          Crul::CLI.run!(["post", "http://example.org/data", "-d", "Hello"], output).should be_true
        end

        lines.first.should eq("HTTP/1.1 200 OK")
        lines.last.should eq("World")
      end

      it "sends the data from a file" do
        WebMock.stub(:post, "http://example.org/data")
          .with(body: File.read(__FILE__))
          .to_return(body: "World")

        lines = capture_lines do |output|
          Crul::CLI.run!(["post", "http://example.org/data", "-d", "@#{__FILE__}"], output).should be_true
        end

        lines.first.should eq("HTTP/1.1 200 OK")
        lines.last.should eq("World")
      end
    end
    describe "Sending headers" do
      it "sends the headers" do
        WebMock.stub(:get, "http://example.org/headers")
          .with(headers: {"Hello" => "World", "Header" => "Value"})
          .to_return(body: "Hello, World")

        lines = capture_lines do |output|
          Crul::CLI.run!(["get", "http://example.org/headers", "-H", "Hello:World", "-H", "Header:Value"], output).should be_true
        end

        lines.first.should eq("HTTP/1.1 200 OK")
        lines.last.should eq("Hello, World")
      end
    end
  end
end
