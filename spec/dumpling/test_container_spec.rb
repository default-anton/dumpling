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

  describe '#clear_mocks' do
    let(:container) { described_class.new }

    context 'when container is empty' do
      subject { container.clear_mocks }

      it { is_expected.to be_nil }
    end

    context 'when container does not contain services but does contain mocks' do
      let(:logger) { double(:logger) }

      subject { -> { container.get(:logger) } }

      before do
        container.mock(:logger, logger)
        container.clear_mocks
      end

      it { is_expected.to raise_error Dumpling::Errors::Container::Missing }
    end

    context 'when container contains services and mocks' do
      let(:logger) { double(:logger) }
      let(:test_logger) { double(:test_logger) }
      let(:container) do
        logger = self.logger
        described_class.new.configure do
          set :logger do |s|
            s.instance logger
          end
        end
      end

      subject { container.get(:logger) }

      before do
        container.mock(:logger, test_logger)
        container.clear_mocks
      end

      it 'returns the original service' do
        expect(subject).to eq logger
      end
    end

    context 'when container contains services but does not contain mocks' do
      let(:logger) { double(:logger) }
      let(:container) do
        logger = self.logger
        described_class.new.configure do
          set :logger do |s|
            s.instance logger
          end
        end
      end

      subject { container.get(:logger) }

      before do
        container.clear_mocks
      end

      it 'returns the original service' do
        expect(subject).to eq logger
      end
    end

    context 'when use #mock after #clear_mocks call' do
      let(:logger) { double(:logger) }
      let(:test_logger) { double(:test_logger) }
      let(:worker) { Struct.new(:logger).new }

      subject { container.get(:worker).logger }

      before do
        container.set(:logger) { |s| s.instance logger }
        container.set(:worker) do |s|
          s.instance worker
          s.dependency :logger
        end

        container.mock(:logger, test_logger)
        container.clear_mocks
        container.mock(:logger, test_logger)
      end

      it 'returns the test service' do
        expect(subject).to eq test_logger
      end
    end
  end
end
