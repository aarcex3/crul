require "./command.cr"
require "./options.cr"

module Crul
  module CLI
    def self.run!(argv : Array(String), output)
      options = Options.parse(argv)

      if options.help?
        output.puts Options::USAGE
        return true
      end

      if options.version?
        output.puts Crul::VERSION
        return true
      end

      if options.errors.any?
        output.puts Options::USAGE

        output.puts "Errors:"
        options.errors.each do |error|
          output.puts "  * " + error.to_s
        end
        output.puts
        return false
      end

      Command.new(output, options).run!
      true
    end
  end
end
