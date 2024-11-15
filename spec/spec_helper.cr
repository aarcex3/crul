require "spec"
require "../src/main.cr"
require "webmock"

struct FakeResponse
  getter :body, :headers

  def initialize(@body = "", content_type = nil)
    @headers = HTTP::Headers.new
    return unless content_type
    @headers["Content-Type"] = content_type
  end
end

abstract class Crul::Formatters::Base
  def initialize(@output : IO, @response : FakeResponse)
  end
end

def uncolorize(string)
  String.build do |output|
    ignore = false
    string.chars.each do |char|
      if ignore
        if char == 'm'
          ignore = false
        end
      else
        if char == '\e'
          ignore = true
        else
          output << char
        end
      end
    end
  end
end

def capture_lines(uncolorize? = true, &)
  output = IO::Memory.new
  yield(output)
  string = output.to_s
  string = uncolorize(string) if uncolorize?
  string.strip.split("\n")
end

Spec.before_each do
  WebMock.reset
end
