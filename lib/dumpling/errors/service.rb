module Dumpling
  module Errors
    module Service
      class Invalid < BaseError
      end

      class MissingDependencies < Invalid
      end
    end
  end
end
