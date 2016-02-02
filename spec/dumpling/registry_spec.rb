require 'spec_helper'

describe Dumpling::Registry do
  let(:instance) { described_class.new }

  describe '#set' do
    subject { instance.set(:test, 'payload') }

    context 'when defines the id for the first time' do
      it { is_expected.to eq 'payload' }

      describe '#keys' do
        before { instance.set(:test, 'payload') }

        subject { instance.keys }

        it { is_expected.to include :test }

        describe '#size' do
          subject { super().size }

          it { is_expected.to eq 1 }
        end
      end
    end

    context 'when defines the id multiple times' do
      before { instance.set(:test, 'payload') }

      it { is_expected.to eq 'payload' }

      describe '#keys' do
        before { instance.set(:test, 'payload') }

        subject { instance.keys }

        it { is_expected.to include :test }

        describe '#size' do
          subject { super().size }

          it { is_expected.to eq 1 }
        end
      end
    end
  end

  describe '#get' do
    subject { instance.get(:test) }

    context 'when the id does not exist' do
      it { is_expected.to be_nil }
    end

    context 'when the id exists' do
      before { instance.set(:test, 'payload') }

      it { is_expected.to eq 'payload' }
    end
  end

  describe '#has?' do
    context 'when the id does not exist' do
      subject { instance.has?(:test) }

      it { is_expected.to be_falsey }
    end

    context 'when the id exists' do
      before { instance.set(:test, 'payload') }

      subject { instance.has?(:test) }

      it { is_expected.to be_truthy }
    end
  end
end
