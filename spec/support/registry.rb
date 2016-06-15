shared_examples 'registry' do
  let(:instance) { described_class.new }

  describe '#set' do
    subject { instance.set(:test, 'payload') }

    context 'when defines an id for the first time' do
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

    context 'when defines an id multiple times' do
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

    context 'when id does not exist' do
      it { is_expected.to be_nil }
    end

    context 'when id exists' do
      before { instance.set(:test, 'payload') }

      it { is_expected.to eq 'payload' }
    end
  end

  describe '#has?' do
    context 'when id does not exist' do
      subject { instance.has?(:test) }

      it { is_expected.to be_falsey }
    end

    context 'when id exists' do
      before { instance.set(:test, 'payload') }

      subject { instance.has?(:test) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#initialize_dup' do
    let(:clone) { instance.dup }

    it { expect(instance).not_to eq clone }

    context 'when original registry is empty' do
      subject { clone.keys }

      it { is_expected.to be_empty }
    end

    context 'when original registry is not empty' do
      before do
        instance.set(:logger, 'MyLogger')
      end

      it { expect(clone.has?(:logger)).to be_truthy }
      it { expect(clone.get(:logger)).to eq 'MyLogger' }

      it 'does not duplicate services' do
        expect(clone.get(:logger)).to equal instance.get(:logger)
      end
    end

    context 'when adding services to the duplicate registry' do
      it 'does not add services to the original registry' do
        clone.set(:sms_notifier, 'MyAwesomeSMSProvider')
        expect(instance.has?(:sms_notifier)).to be_falsey
        expect(instance.get(:sms_notifier)).to be_nil
      end
    end

    context 'when adding services to the original registry' do
      let!(:clone) { instance.dup }

      it 'does not add services to the duplicate' do
        instance.set(:sms_notifier, 'MyAwesomeSMSProvider')
        expect(clone.has?(:sms_notifier)).to be_falsey
        expect(clone.get(:sms_notifier)).to be_nil
      end
    end
  end
end
