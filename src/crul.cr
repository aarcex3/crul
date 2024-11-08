require "./formatters/auto.cr"
require "./formatters/json.cr"
require "./formatters/plain.cr"
require "./formatters/xml.cr"

require "./cli.cr"
require "./command.cr"
require "./cookie_store.cr"
require "./formatters.cr"
require "./methods.cr"
require "./options.cr"

module Crul
  def self.run
    success = Crul::CLI.run!(argv: ARGV, output: STDOUT)

    exit success ? 0 : -1
  end
end

Crul.run
