require 'spec_helper'

describe Dumpling::SpecificationValidator do
  let(:id_list) { Set.new }
  let(:specification) { Dumpling::Specification.new }
  let(:validator) { described_class.new(id_list, specification) }
  let(:klass) { Class.new }

  subject { -> { validator.validate! } }

  context 'when #class is defined' do
    before do
      specification.class klass
    end

    it { is_expected.not_to raise_error }
  end

  context 'when #instance is defined' do
    let(:instance) { klass.new }

    before do
      specification.instance instance
    end

    it { is_expected.not_to raise_error }
  end

  context 'when both #class and #instance are defined at the same time' do
    let(:instance) { klass.new }

    before do
      specification.class klass
      specification.instance instance
    end

    it { is_expected.to raise_error Dumpling::Errors::Specification::Invalid }
  end

  context 'when both #class and #instance are not defined' do
    it { is_expected.to raise_error Dumpling::Errors::Specification::Invalid }
  end

  describe 'dependencies' do
    context 'when all dependencies exist' do
      let(:id_list) { Set.new([:logger, :repository]) }

      before do
        specification.class klass
        specification.dependency :logger
        specification.dependency :repository
      end

      it { is_expected.not_to raise_error }
    end

    context 'when a dependency does not exist' do
      let(:id_list) { Set.new([:notifier]) }
      let(:error) { Dumpling::Errors::Specification::MissingDependencies }

      before do
        specification.class klass
        specification.dependency :logger
        specification.dependency :notifier
      end

      it { is_expected.to raise_error error, 'logger' }
    end

    context 'when multiple dependencies do not exist' do
      let(:error) { Dumpling::Errors::Specification::MissingDependencies }

      before do
        specification.class klass
        specification.dependency :logger
        specification.dependency :mailer
      end

      it { is_expected.to raise_error error, 'logger, mailer' }
    end
  end
end
