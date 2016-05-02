module Dumpling
  module Version
    MAJOR = 0
    MINOR = 3
    TINY = 1
    PRE = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.').freeze
  end
end
