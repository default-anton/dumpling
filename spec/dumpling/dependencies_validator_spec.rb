require 'spec_helper'

describe Dumpling::DependenciesValidator do
  let(:services) { Set.new }
  let(:abstract_services) { Set.new }
  let(:specification) { Dumpling::ServiceSpecification.new }
  let(:validator) { described_class.new(services, abstract_services) }
  let(:error_class) { Dumpling::Errors::Service::MissingDependencies }
  let(:klass) { Class.new }

  subject { -> { validator.validate(specification) } }

  context 'when specification has no dependencies' do
    before do
      specification.class klass
    end

    it { is_expected.not_to raise_error }
  end

  context 'when specification has multiple dependencies' do
    let(:services) { Set.new([:logger, :repository]) }

    before do
      specification.class klass
      specification.dependency :logger
      specification.dependency :repository
    end

    it { is_expected.not_to raise_error }
  end

  context 'when a dependency is missing' do
    let(:services) { Set.new([:notifier]) }

    before do
      specification.class klass
      specification.dependency :logger
      specification.dependency :notifier
    end

    it { is_expected.to raise_error error_class, ':logger' }
  end

  context 'when multiple dependencies are missing' do
    before do
      specification.class klass
      specification.dependency :logger
      specification.dependency :mailer
    end

    it { is_expected.to raise_error error_class, ':logger, :mailer' }
  end

  context 'when specification has no abstract dependencies' do
    before do
      specification.class klass
    end

    it { is_expected.not_to raise_error }
  end

  context 'when specification has multiple abstract dependencies' do
    let(:abstract_services) { Set.new([:logger, :repository]) }

    before do
      specification.class klass
      specification.include :repository
    end

    it { is_expected.not_to raise_error }
  end

  context 'when an abstract dependency is missing' do
    let(:abstract_services) { Set.new([:notifier]) }

    before do
      specification.class klass
      specification.include :logger
      specification.include :notifier
    end

    it { is_expected.to raise_error error_class, ':logger(abstract)' }
  end

  context 'when multiple abstract dependencies are missing' do
    before do
      specification.class klass
      specification.include :logger
      specification.include :mailer
    end

    it { is_expected.to raise_error error_class, ':logger(abstract), :mailer(abstract)' }
  end

  context 'when both dependencies and abstract dependencies are missing' do
    let(:list_of_missing_dependencies) do
      ':dispatcher, :receiver, :logger(abstract), :mailer(abstract)'
    end

    before do
      specification.class klass
      specification.include :logger
      specification.include :mailer
      specification.dependency :dispatcher
      specification.dependency :receiver
    end

    it { is_expected.to raise_error error_class, list_of_missing_dependencies }
  end
end
