require "./spec_helper"

describe "Crul::Formatters" do
  describe Crul::Formatters::Auto do
    describe ".formatters" do
      it "detects JSON" do
        output = IO::Memory.new
        response = FakeResponse.new(content_type: "application/json")
        formatter = Crul::Formatters::Auto.new(output: output, response: response)

        formatter.formatter.should be_a(Crul::Formatters::JSON)
      end

      it "detects JSONAPI" do
        output = IO::Memory.new
        response = FakeResponse.new(content_type: "application/vnd.api+json")
        formatter = Crul::Formatters::Auto.new(output: output, response: response)

        formatter.formatter.should be_a(Crul::Formatters::JSON)
      end

      it "detects XML" do
        output = IO::Memory.new
        response = FakeResponse.new(content_type: "application/xml")
        formatter = Crul::Formatters::Auto.new(output: output, response: response)

        formatter.formatter.should be_a(Crul::Formatters::XML)
      end

      it "defaults to plain" do
        output = IO::Memory.new
        response = FakeResponse.new(content_type: "text/csv")
        formatter = Crul::Formatters::Auto.new(output: output, response: response)

        formatter.formatter.should be_a(Crul::Formatters::Plain)
      end

      it "works without a header" do
        output = IO::Memory.new
        response = FakeResponse.new
        formatter = Crul::Formatters::Auto.new(output: output, response: response)

        formatter.formatter.should be_a(Crul::Formatters::Plain)
      end

      it "works with an encoding" do
        output = IO::Memory.new
        response = FakeResponse.new(content_type: "application/xml; charset=ISO-8859-1")
        formatter = Crul::Formatters::Auto.new(output: output, response: response)

        formatter.formatter.should be_a(Crul::Formatters::XML)
      end
    end
  end

  # JSON Formatter Tests
  describe Crul::Formatters::JSON do
    describe ".print" do
      context "with valid JSON" do
        it "formats it" do
          output = IO::Memory.new
          response = FakeResponse.new("{\"a\":1}")
          formatter = Crul::Formatters::JSON.new(output: output, response: response)

          formatter.print

          Hash(String, Int32).from_json(uncolorize(output.to_s)).should eq({"a" => 1})
        end
      end

      context "with invalid JSON" do
        it "formats it (falling back to plain)" do
          output = IO::Memory.new
          response = FakeResponse.new("{{{")
          formatter = Crul::Formatters::JSON.new(output: output, response: response)

          formatter.print

          output.to_s.strip.should eq("{{{")
        end
      end
    end
  end

  # Plain Formatter Tests
  describe Crul::Formatters::Plain do
    describe ".print" do
      it "prints" do
        output = IO::Memory.new
        response = FakeResponse.new(body: "Hello")
        formatter = Crul::Formatters::Plain.new(output: output, response: response)

        formatter.print

        output.to_s.strip.should eq("Hello")
      end
    end
  end

  # XML Formatter Tests
  describe Crul::Formatters::XML do
    describe ".print" do
      context "with valid XML" do
        it "formats it" do
          output = IO::Memory.new
          response = FakeResponse.new("<a><b>c</b></a>")
          formatter = Crul::Formatters::XML.new(output: output, response: response)

          formatter.print
        end
      end

      context "with malformed XML" do
        it "formats it (falling back to plain)" do
          output = IO::Memory.new
          response = FakeResponse.new("<<<")
          formatter = Crul::Formatters::XML.new(output: output, response: response)

          formatter.print

          output.to_s.strip.should eq("<<<")
        end
      end
    end
  end
end
