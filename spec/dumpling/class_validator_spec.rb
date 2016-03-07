require 'spec_helper'

describe Dumpling::ClassValidator do
  let(:id_list) { Set.new }
  let(:specification) { Dumpling::ServiceSpecification.new }
  let(:validator) { described_class.new }
  let(:klass) { Class.new }

  subject { -> { validator.validate(specification) } }

  context 'when #class is defined' do
    before { specification.class klass }

    it { is_expected.not_to raise_error }
  end

  context 'when #instance is defined' do
    let(:instance) { klass.new }

    before { specification.instance instance }

    it { is_expected.not_to raise_error }
  end

  context 'when both #class and #instance are defined at the same time' do
    let(:instance) { klass.new }

    before do
      specification.class klass
      specification.instance instance
    end

    it { is_expected.to raise_error Dumpling::Errors::Service::Invalid }
  end

  context 'when both #class and #instance are not defined' do
    it { is_expected.to raise_error Dumpling::Errors::Service::Invalid }
  end
end
