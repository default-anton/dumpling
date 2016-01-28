module Dumpling
  module Version
    MAJOR = 0
    MINOR = 1
    TINY = 0
    PRE = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.').freeze
  end
end
