module Dumpling
  module Errors
    module Specification
      class Invalid < BaseError
      end

      class MissingDependencies < Invalid
      end
    end
  end
end
