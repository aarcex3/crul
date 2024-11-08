require "xml"
require "colorize"
require "../formatters.cr"

module Crul
  module Formatters
    class XML < Base
      def print
        printer = PrettyPrinter.new(input: @response.body, output: @output)
        if printer.valid_xml?
          printer.print
          @output.puts
        else
          print_plain
        end
      end

      class PrettyPrinter
        def initialize(@input : IO | String, @output : IO)
          @reader = ::XML::Reader.new(@input)
          @indent = 0
        end

        def valid_xml?
          xml = ::XML.parse(@input)
          !xml.errors
        end

        def print
          current = Element.new

          while @reader.read
            case @reader.node_type
            when ::XML::Reader::Type::ELEMENT
              elem = Element.new(name: @reader.name, parent: current)
              empty = @reader.empty_element?
              current = elem unless empty

              print_start_open_element(name: elem.name)

              if @reader.has_attributes?
                if @reader.move_to_first_attribute
                  print_attribute(@reader.name, @reader.value)
                  while @reader.move_to_next_attribute
                    print_attribute(@reader.name, @reader.value)
                  end
                end
              end

              print_end_open_element(empty: empty)
            when ::XML::Reader::Type::END_ELEMENT
              parent = current.parent
              raise "Invalid end element" unless parent

              print_close_element(current.name)
              current = parent
            when ::XML::Reader::Type::TEXT
              print_text @reader.value
            when ::XML::Reader::Type::COMMENT
              print_comment(@reader.value)
            end
          end
        end

        private def print_start_open_element(name : String | Nil)
          Colorize.with.cyan.surround(@output) do
            @output << "#{"  " * @indent}<#{name}"
          end
        end

        private def print_end_open_element(empty : Bool)
          Colorize.with.cyan.surround(@output) do
            if empty
              @output << "/>\n"
            else
              @indent += 1
              @output << ">\n"
            end
          end
        end

        private def print_close_element(name : String | Nil)
          @indent -= 1
          Colorize.with.cyan.surround(@output) do
            @output << "#{"  " * @indent}</#{name}>\n"
          end
        end

        private def print_attribute(name : String | Nil, value : String | Nil)
          Colorize.with.cyan.surround(@output) do
            @output << " #{name}="
          end
          Colorize.with.yellow.surround(@output) do
            @output << "\"#{value}\""
          end
        end

        private def print_text(text)
          Colorize.with.yellow.surround(@output) do
            @output << "#{"  " * @indent}#{text.strip}\n"
          end
        end

        private def print_comment(comment : String)
          Colorize.with.light_blue.surround(@output) do
            @output << "#{"  " * @indent}<!-- #{comment.strip} -->\n"
          end
        end

        class Element
          getter :name, :parent

          def initialize(@name : String? = nil, @parent : Element? = nil)
          end
        end
      end
    end
  end
end
