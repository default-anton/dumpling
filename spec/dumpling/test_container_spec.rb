require 'spec_helper'

describe Dumpling::TestContainer do
  it_behaves_like 'container'

  describe '#mock' do
    let(:container) { described_class.new }
    let(:my_logger) { double(:my_logger) }

    describe 'method result' do
      subject { container.mock(:logger, my_logger) }

      it { is_expected.to eq my_logger }
    end

    context 'when #mock introduces new service' do
      subject { container.get(:logger) }

      before do
        container.mock(:logger, my_logger)
      end

      it { is_expected.to eq my_logger }
    end

    context 'when #mock overrides existing service' do
      let(:real_logger) { double(:real_logger) }

      subject { container.get(:logger) }

      before do
        container.set(:logger) { |s| s.instance real_logger }
        container.mock(:logger, my_logger)
      end

      it { is_expected.to eq my_logger }
    end

    context 'when #mock a dependency of concrete service' do
      let(:logger) { double(:logger) }
      let(:worker) { Struct.new(:logger).new }

      subject { container.get(:worker).logger }

      before do
        container.set(:logger) { |s| s.instance logger }
        container.set(:worker) do |s|
          s.instance worker
          s.dependency :logger
        end
        container.mock(:logger, my_logger)
      end

      it { is_expected.to eq my_logger }

      context 'when container is duplicated' do
        subject { container.dup.get(:worker).logger }

        it { is_expected.to eq my_logger }
      end
    end
  end
end
