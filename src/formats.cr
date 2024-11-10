# Sorted imports
require "./cookie_store"
require "./formats"
require "./methods"
require "colorize"
require "http/client"
require "http/headers"
require "json"
require "json/pull_parser"
require "option_parser"
require "uri"
require "xml"

module Crul
  enum Formats
    Auto
    XML
    JSON
    Plain
  end

  module Formatters
    MAP = {
      Formats::Auto  => Formatters::Auto,
      Formats::XML   => Formatters::XML,
      Formats::JSON  => Formatters::JSON,
      Formats::Plain => Formatters::Plain,
    }

    def self.new(format, *args)
      MAP[format].new(*args)
    end

    # Abstract base formatter class
    abstract class Base
      def initialize(@output : IO, @response : HTTP::Client::Response)
      end

      def print_plain
        Plain.new(@output, @response).print
      end
    end

    class Auto
      @formatter : Crul::Formatters::Base

      getter :formatter

      def initialize(output, response)
        content_type = response.headers.fetch("Content-type", "text/plain").split(';').first
        formatter_class = case content_type
                          when "application/json", "application/vnd.api+json" then JSON
                          when "application/xml"                              then XML
                          else                                                     Plain
                          end
        @formatter = formatter_class.new(output, response)
      end

      def print(*args)
        @formatter.print(*args)
      end
    end

    class JSON < Crul::Formatters::Base
      def print
        printer = PrettyPrinter.new(@response.body, @output)
        printer.print
        @output.puts
      rescue ::JSON::ParseException
        print_plain
      end

      # Pretty printer for JSON
      class PrettyPrinter
        def initialize(@input : IO | String, @output : IO)
          @pull = ::JSON::PullParser.new @input
          @indent = 0
        end

        def print
          read_any
        end

        def read_any
          case @pull.kind
          when .null?
            Colorize.with.bold.surround(@output) { @pull.read_null.to_json(@output) }
          when .bool?
            Colorize.with.light_blue.surround(@output) { @pull.read_bool.to_json(@output) }
          when .int?
            Colorize.with.red.surround(@output) { @pull.read_int.to_json(@output) }
          when .float?
            Colorize.with.red.surround(@output) { @pull.read_float.to_json(@output) }
          when .string?
            Colorize.with.yellow.surround(@output) { @pull.read_string.to_json(@output) }
          when .begin_array?
            read_array
          when .begin_object?
            read_object
          when .eof?
          else
            raise "Unexpected kind: #{@pull.kind}"
          end
        end

        def read_array
          print "[\n"
          @indent += 1
          i = 0
          @pull.read_array do
            print ",\n" if i > 0
            print_indent
            read_any
            i += 1
          end
          @indent -= 1
          print "\n"
          print_indent
          print ']'
        end

        def read_object
          print "{\n"
          @indent += 1
          i = 0
          @pull.read_object do |key|
            print ",\n" if i > 0
            print_indent
            Colorize.with.cyan.surround(@output) { key.to_json(@output) }
            print ": "
            read_any
            i += 1
          end
          @indent -= 1
          print "\n"
          print_indent
          print '}'
        end

        def print_indent
          @output << "  " * @indent
        end

        def print(value)
          @output << value
        end
      end
    end

    # Plain Formatter
    class Plain < Crul::Formatters::Base
      def print
        @output.puts @response.body
      end
    end

    # XML Formatter
    class XML < Crul::Formatters::Base
      def print
        printer = PrettyPrinter.new(@response.body, @output)
        if printer.valid_xml?
          printer.print
          @output.puts
        else
          print_plain
        end
      end

      # Pretty printer for XML
      class PrettyPrinter
        def initialize(@input : IO | String, @output : IO)
          @reader = ::XML::Reader.new(@input)
          @indent = 0
        end

        def valid_xml?
          xml = ::XML.parse(@input)
          !xml.errors
        end

        class Element
          getter :name, :parent

          def initialize(@name : String? = nil, @parent : Element? = nil)
          end
        end

        def print
          current = Element.new

          while @reader.read
            case @reader.node_type
            when ::XML::Reader::Type::ELEMENT
              elem = Element.new(@reader.name, current)
              empty = @reader.empty_element?
              current = elem unless empty

              print_start_open_element elem.name

              if @reader.has_attributes?
                if @reader.move_to_first_attribute
                  print_attribute @reader.name, @reader.value
                  while @reader.move_to_next_attribute
                    print_attribute @reader.name, @reader.value
                  end
                end
              end

              print_end_open_element empty
            when ::XML::Reader::Type::END_ELEMENT
              parent = current.parent
              raise "Invalid end element" unless parent

              print_close_element current.name
              current = parent
            when ::XML::Reader::Type::TEXT
              print_text @reader.value
            when ::XML::Reader::Type::COMMENT
              print_comment @reader.value
            end
          end
        end

        private def print_start_open_element(name)
          Colorize.with.cyan.surround(@output) { @output << "#{"  " * @indent}<#{name}" }
        end

        private def print_end_open_element(empty)
          Colorize.with.cyan.surround(@output) { @output << (empty ? "/>\n" : ">\n") }
          @indent += 1 unless empty
        end

        private def print_close_element(name)
          @indent -= 1
          Colorize.with.cyan.surround(@output) { @output << "#{"  " * @indent}</#{name}>\n" }
        end

        private def print_attribute(name, value)
          Colorize.with.cyan.surround(@output) { @output << " #{name}=" }
          Colorize.with.yellow.surround(@output) { @output << "\"#{value}\"" }
        end

        private def print_text(text)
          Colorize.with.yellow.surround(@output) { @output << "#{"  " * @indent}#{text.strip}\n" }
        end

        private def print_comment(comment)
          Colorize.with.light_blue.surround(@output) { @output << "#{"  " * @indent}<!-- #{comment.strip} -->\n" }
        end
      end
    end
  end
end
