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
      specification = Dumpling::ServiceSpecification.new
      specification.instance 'string1'
      specification
    end
    let(:second_dependency) do
      specification = Dumpling::ServiceSpecification.new
      specification.instance 'string2'
      specification
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

  xdescribe 'nested dependencies' do
    let(:logger_class) { Class.new }
    let(:adapter_instance) do
      klass = Class.new { attr_accessor :logger }
      klass.new
    end
    let(:repository_instance) do
      klass = Class.new { attr_accessor :adapter }
      klass.new
    end

    before do
      logger_class = self.logger_class
      adapter_instance = self.adapter_instance
      repository_instance = self.repository_instance

      container.configure do
        set :logger do |s|
          s.class logger_class
        end

        set :adapter do |s|
          s.instance adapter_instance
          s.dependency :logger
        end

        set :repository do |s|
          s.instance repository_instance
          s.dependency :adapter
        end
      end
    end

    subject { container.get(:repository) }

    it { is_expected.to eq repository_instance }

    describe 'top tier dependency' do
      subject { super().adapter }

      it { is_expected.to eq adapter_instance }
    end

    describe 'the lower tier dependency' do
      subject { super().adapter.logger }

      it { is_expected.to be_an_instance_of logger_class }
    end
  end

  xcontext 'when the dependency is defined by a private attr_accessor' do
    let(:repository_instance) do
      klass = Class.new do
        attr_accessor :symbol
        private :symbol, :symbol=
      end
      klass.new
    end

    before do
      repository_instance = self.repository_instance

      container.configure do
        set :symbol do |s|
          s.instance :strong_symbol
        end

        set :repository do |s|
          s.instance repository_instance
          s.dependency :symbol
        end
      end
    end

    subject { container.get(:repository) }

    it { is_expected.to eq repository_instance }

    describe 'dependency' do
      subject { super().send(:symbol) }

      it { is_expected.to eq :strong_symbol }
    end
  end

  xcontext 'when the service include abstract services' do
    let(:logger_instance) { 'Logger.new(STDOUT)' }
    let(:users_repository_class) do
      Class.new { attr_accessor :logger }
    end

    before do
      logger_instance = self.logger_instance
      users_repository_class = self.users_repository_class

      container.set :logger do |s|
        s.instance logger_instance
      end

      container.abstract :repository do |s|
        s.dependency :logger
      end

      container.set :users_repository do |s|
        s.include :repository
        s.class users_repository_class
      end
    end

    subject { container[:users_repository] }

    it { is_expected.to be_an_instance_of users_repository_class }

    describe 'injection of a dependency from abstract service' do
      subject { super().logger }

      it { is_expected.to eq logger_instance }
    end

    context 'when the service overrides abstract service dependency' do
      let(:posts_repository_class) do
        Class.new { attr_accessor :my_logger }
      end

      before do
        posts_repository_class = self.posts_repository_class

        container.set :posts_repository do |s|
          s.include :repository
          s.class posts_repository_class
          s.dependency :logger, attribute: :my_logger
        end
      end

      subject { container[:posts_repository].my_logger }

      it { is_expected.to eq logger_instance }
    end
  end
end
