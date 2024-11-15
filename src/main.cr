require "./cli.cr"
require "./command.cr"
require "./cookie_store.cr"
require "./formats.cr"

require "./methods.cr"
require "./options.cr"

module Crul
  VERSION = "0.2.0"

  def self.run
    success = Crul::CLI.run!(argv: ARGV, output: STDOUT)

    exit success ? 0 : -1
  end
end
