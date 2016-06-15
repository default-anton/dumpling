module Dumpling
  class TestContainer < Container
    def initialize
      super
      @services = TestRegistry.new(@services)
    end

    def mock(id, service)
      spec = create_specification { |s| s.instance service }
      @services.mock(id, spec)
      service
    end
  end
end
