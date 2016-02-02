require 'spec_helper'

describe Dumpling do
  subject { described_class }

  describe 'version' do
    subject { Dumpling::Version::STRING }

    it { is_expected.not_to be_nil }
  end

  describe 'delegations' do
    let(:container_class) { Dumpling::Container }

    describe '.get' do
      before do
        expect_any_instance_of(container_class).to receive(:get).with(:test).and_return(:ok)
      end

      subject { super().get(:test) }

      it { is_expected.to eq :ok }
    end

    describe '.set' do
      before do
        expect_any_instance_of(container_class).to receive(:set).with(:test).and_return(:ok)
      end

      subject { super().set(:test) }

      it { is_expected.to eq :ok }
    end

    describe '.[]' do
      before do
        expect_any_instance_of(container_class).to receive(:[]).with(:test).and_return(:ok)
      end

      subject { super()[:test] }

      it { is_expected.to eq :ok }
    end

    describe '.configure' do
      let(:block) { proc {} }

      before do
        expect_any_instance_of(container_class).to receive(:configure).with(block).and_return(:ok)
      end

      subject { super().configure(block) }

      it { is_expected.to eq :ok }
    end
  end
end
