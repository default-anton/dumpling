require 'spec_helper'

describe Dumpling::ServiceBuilder do
  let(:services) { Dumpling::Registry.new }
  let(:abstract_services) { Dumpling::Registry.new }
  let(:builder) { described_class.new(services, abstract_services) }
  let(:service_class) { Class.new }
  let(:service_instance) { service_class.new }
  let(:service_specification) { Dumpling::ServiceSpecification.new }

  before { services.set(:service, service_specification) }

  subject { builder.build(service_specification) }

  context 'when service is configured to use an instance' do
    before { service_specification.instance service_instance }

    it { is_expected.to eq service_instance }
  end

  context 'when service is configured to use a class' do
    before { service_specification.class service_class }

    it { is_expected.to be_an_instance_of service_class }
  end

  context 'when service has multiple dependencies' do
    let(:service_class) do
      Class.new do
        attr_accessor :first_string, :second_string

        private :first_string=, :second_string=
      end
    end
    let(:first_dependency) do
      spec = Dumpling::ServiceSpecification.new
      spec.instance 'string1'
      spec
    end
    let(:second_dependency) do
      spec = Dumpling::ServiceSpecification.new
      spec.instance 'string2'
      spec
    end

    before do
      services.set(:first_string, first_dependency)
      services.set(:second_string, second_dependency)

      service_specification.dependency :first_string
      service_specification.dependency :second_string
    end

    context 'when service is configured to use an instance' do
      before { service_specification.instance service_instance }

      it { is_expected.to eq service_instance }

      describe 'dependencies' do
        subject { [super().first_string, super().second_string] }

        it { is_expected.to eq %w(string1 string2) }
      end
    end

    context 'when service is configured to use a class' do
      before { service_specification.class service_class }

      it { is_expected.to be_an_instance_of service_class }

      describe 'dependencies' do
        subject { [super().first_string, super().second_string] }

        it { is_expected.to eq %w(string1 string2) }
      end
    end
  end

  describe 'nested dependencies' do
    let(:logger_class) { Class.new }
    let(:adapter_instance) do
      klass = Class.new do
        private
        attr_accessor :logger
      end
      klass.new
    end
    let(:service_instance) do
      klass = Class.new do
        private
        attr_accessor :adapter
      end
      klass.new
    end
    let(:logger_specification) do
      spec = Dumpling::ServiceSpecification.new
      spec.class logger_class
      spec
    end
    let(:adapter_specification) do
      spec = Dumpling::ServiceSpecification.new
      spec.instance adapter_instance
      spec.dependency :logger
      spec
    end
    let(:service_specification) do
      spec = Dumpling::ServiceSpecification.new
      spec.instance service_instance
      spec.dependency :adapter
      spec
    end

    before do
      services.set(:logger, logger_specification)
      services.set(:adapter, adapter_specification)
    end

    it { is_expected.to eq service_instance }

    describe 'top tier dependency' do
      subject { super().send(:adapter) }

      it { is_expected.to eq adapter_instance }
    end

    describe 'the lower tier dependency' do
      subject { super().send(:adapter).send(:logger) }

      it { is_expected.to be_an_instance_of logger_class }
    end
  end

  context 'when a service depends on an abstract services' do
    let(:logger_instance) { 'Logger.new(STDOUT)' }
    let(:service_class) do
      Class.new { attr_accessor :logger }
    end
    let(:logger_specification) do
      spec = Dumpling::ServiceSpecification.new
      spec.instance logger_instance
      spec
    end
    let(:adapter_specification) do
      spec = Dumpling::ServiceSpecification.new
      spec.dependency :logger
      spec
    end
    let(:service_specification) do
      spec = Dumpling::ServiceSpecification.new
      spec.include :adapter
      spec.class service_class
      spec
    end

    before do
      services.set(:logger, logger_specification)
      abstract_services.set(:adapter, adapter_specification)
    end

    it { is_expected.to be_an_instance_of service_class }

    describe 'injection of a dependency from an abstract service' do
      subject { super().logger }

      it { is_expected.to eq logger_instance }
    end

    context 'when a service overrides an abstract service dependency' do
      let(:service_class) do
        Class.new { attr_accessor :my_logger }
      end
      let(:service_specification) do
        spec = Dumpling::ServiceSpecification.new
        spec.include :adapter
        spec.class service_class
        spec.dependency :logger, attribute: :my_logger
        spec
      end

      subject { super().my_logger }

      it { is_expected.to eq logger_instance }
    end

    context 'when an abstract service in turn depends on another abstract service' do
      let(:service_class) do
        Class.new { attr_accessor :logger, :connection }
      end
      let(:connection_instance) { 'DB_CONNECTION' }
      let(:connection_specification) do
        spec = Dumpling::ServiceSpecification.new
        spec.instance connection_instance
        spec
      end
      let(:base_adapter_specification) do
        spec = Dumpling::ServiceSpecification.new
        spec.dependency :connection
        spec
      end
      let(:adapter_specification) do
        spec = Dumpling::ServiceSpecification.new
        spec.include :base_adapter
        spec.dependency :logger
        spec
      end

      before do
        services.set(:connection, connection_specification)
        abstract_services.set(:base_adapter, base_adapter_specification)
      end

      subject { super().connection }

      it { is_expected.to eq connection_instance }
    end
  end
end
