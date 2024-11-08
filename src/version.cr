module Crul
  VERSION = "0.1.0"

  def self.version_string
    "crul #{VERSION} (#{{{`date -u`.strip.stringify}}})"
  end
end
