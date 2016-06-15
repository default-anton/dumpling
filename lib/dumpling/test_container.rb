module Dumpling
  class TestContainer < Container
    def initialize
      super
      @original_services = Registry.new
      init_test_registry
    end

    def mock(id, service)
      spec = create_specification { |s| s.instance service }
      @services.mock(id, spec)
      service
    end

    def clear_mocks
      init_test_registry
      nil
    end

    private

    def init_test_registry
      @services = TestRegistry.new(@original_services)
    end
  end
end
