# Imports (sorted alphabetically)
require "./cookie_store"
require "./formats"
require "./methods"
require "http/headers"
require "option_parser"
require "uri"

module Crul
  class Options
    property! url : URI
    property! parser : OptionParser?
    property method : Crul::Methods = Methods::GET
    property format : Crul::Formats = Crul::Formats::Auto
    property basic_auth : Tuple(String, String)?
    property headers : HTTP::Headers = HTTP::Headers.new
    property cookie_store : Crul::CookieStore = CookieStore.new
    property body : String?
    property errors : Array(Exception) = [] of Exception

    private def self.configure_parser(args : Array(String), options : Options) : OptionParser
      OptionParser.parse(args: args) do |parser|
        parser.separator "HTTP options:"
        define_data_option(parser: parser, options: options)
        define_format_options(parser, options)
        define_header_option(parser, options)
        define_auth_option(parser, options)
        define_cookie_option(parser, options)
      end
    end

    private def self.define_auth_option(parser : OptionParser, options : Options)
      parser.on("-a USER:PASS", "--auth USER:PASS", "Basic auth") do |user_pass|
        pieces = user_pass.split(':', 2)
        options.basic_auth = {pieces[0], pieces[1]? || ""}
      end
    end

    private def self.define_cookie_option(parser : OptionParser, options : Options)
      parser.on("-c FILE", "--cookies FILE", "Use FILE as cookie store (reads and writes)") do |file|
        options.cookie_store.load(filename: file)
      end
    end

    private def self.define_data_option(parser : OptionParser, options : Options)
      parser.on("-d DATA", "--data DATA", "Request body") do |body|
        options.body = body.starts_with?('@') ? load_body_from_file(filename: body[1..-1], options: options) : body
      end
    end

    private def self.define_format_options(parser : OptionParser, options : Options)
      parser.on("-j", "--json", "Format response as JSON") { options.format = Formats::JSON }
      parser.on("-x", "--xml", "Format response as XML") { options.format = Formats::XML }
      parser.on("-p", "--plain", "Format response as plain text") { options.format = Formats::Plain }
    end

    private def self.define_header_option(parser : OptionParser, options : Options)
      parser.on("-H HEADER", "--header HEADER", "Set header") do |header|
        name, value = header.split(':', 2)
        options.headers[name] = value
      end
    end

    private def self.extract_method(args : Array(String)) : Crul::Methods
      case args.first?.try(&.upcase)
      when "GET"    then args.shift; Methods::GET
      when "POST"   then args.shift; Methods::POST
      when "PUT"    then args.shift; Methods::PUT
      when "DELETE" then args.shift; Methods::DELETE
      else               Methods::GET
      end
    end

    def self.parse(args : Array(String))
      new.tap do |options|
        options.method = extract_method(args: args)

        if args.empty?
          raise ArgumentError.new("URL is required")
        end

        options.url = parse_url(raw_url: args.first)
        options.parser = configure_parser(args: args, options: options)
      end
    end

    private def self.parse_url(raw_url : String) : URI
      uri = URI.parse(raw_url: raw_url)
      uri.host.nil? ? URI.parse(raw_url: "http://#{raw_url}") : uri
    end

    private def self.load_body_from_file(filename : String, options : Options) : String?
      File.read(filename: filename)
    rescue e
      options.errors << e
      nil
    end
  end
end
