shared_examples 'container' do
  let(:container) { described_class.new }

  describe '#set' do
    context 'when service is valid' do
      let(:repository_class) { Class.new }
      let!(:declaration) do
        repository_class = self.repository_class

        container.set :repository do |s|
          s.class repository_class
        end
      end

      subject { declaration }

      it { is_expected.to eq :repository }

      describe '#get' do
        subject { container.get(:repository) }

        it { is_expected.to be_an_instance_of repository_class }
      end
    end

    context 'when service is invalid' do
      subject do
        container.set :repository do
        end
      end

      it 'does not define an invalid service' do
        expect { subject }.to raise_error Dumpling::Errors::Service::Invalid
        expect { container.get(:repository) }.to raise_error Dumpling::Errors::Container::Missing
      end
    end

    context 'when service is duplicated' do
      let(:repository_class) { Class.new }
      let(:duplicated_repository_class) { Class.new }

      before do
        repository_class = self.repository_class

        container.set :repository do |s|
          s.class repository_class
        end
      end

      subject do
        duplicated = duplicated_repository_class

        container.set :repository do |s|
          s.class duplicated
        end
      end

      it 'does not overwrite the service' do
        expect { subject }.to raise_error Dumpling::Errors::Container::Duplicate
        expect(container.get(:repository)).to be_an_instance_of repository_class
      end
    end
  end

  describe '#abstract' do
    let(:logger_class) { Class.new }
    let(:repository_class) do
      Class.new { attr_accessor :logger }
    end
    let(:declaration) do
      logger_class = self.logger_class

      container.set :logger do |s|
        s.class logger_class
      end

      container.abstract :repository do |s|
        s.dependency :logger
      end
    end

    subject { declaration }

    it { is_expected.to eq :repository }

    context 'when accessing an abstract service via the #get method' do
      let!(:declaration) { super() }

      subject { -> { container.get(:repository) } }

      it { is_expected.to raise_error Dumpling::Errors::Container::Missing }
    end

    context 'when service is invalid' do
      let(:declaration) do
        container.abstract :repository do |s|
          s.dependency :logger
        end
      end

      it 'does not define an invalid service' do
        expect { subject }.to raise_error Dumpling::Errors::Service::MissingDependencies
      end
    end

    context 'when the service is duplicated' do
      let(:logger_class) { Class.new }
      let(:repository_class) { Class.new { attr_accessor :logger } }
      let(:declaration) do
        container.abstract :repository do |s|
          s.dependency :logger
        end
      end

      before do
        logger_class = self.logger_class

        container.set :logger do |s|
          s.class logger_class
        end

        container.abstract :repository do |s|
          s.dependency :logger
        end
      end

      subject { -> { declaration } }

      it { is_expected.to raise_error Dumpling::Errors::Container::Duplicate }
    end
  end

  describe '#get' do
    context 'when the service exists' do
      let(:repository_class) { Class.new }

      before do
        repository_class = self.repository_class

        container.set :repository do |s|
          s.class repository_class
        end
      end

      subject { container.get(:repository) }

      it { is_expected.to be_an_instance_of repository_class }
    end

    context 'when the service does not exist' do
      subject { -> { container.get(:repository) } }

      it { is_expected.to raise_error Dumpling::Errors::Container::Missing }
    end
  end

  describe '#configure' do
    describe 'return value' do
      subject { container.configure {} }

      it { is_expected.to eq container }
    end

    describe 'configuration' do
      let(:configuration) do
        container.configure do
          set :game do |s|
            s.instance 'Tetris'
          end

          abstract :gaming_console do |s|
            s.dependency :game, attribute: :tetris
          end
        end
      end

      subject { -> { configuration } }

      it { is_expected.not_to raise_error }

      it 'defines a service' do
        expect(configuration.get(:game)).to eq 'Tetris'
      end
    end
  end

  describe '#initialize_dup' do
    subject { container.dup }

    context 'when container is empty' do
      it { is_expected.not_to eq container }
    end

    context 'when container is not empty' do
      before do
        container.set(:left_arm) { |s| s.instance 'Left' }
        container.set(:right_arm) { |s| s.instance 'Right' }
        container.abstract :arms do |s|
          s.dependency :left_arm
          s.dependency :right_arm
        end
        container.set(:human) do |s|
          s.instance Class.new { attr_accessor :left_arm, :right_arm }.new
          s.include :arms
        end
      end

      subject { container.dup.get(:human) }

      it 'duplicates all services' do
        expect(subject).to equal container.get(:human)
        expect(subject.left_arm).to equal container.get(:human).left_arm
        expect(subject.right_arm).to equal container.get(:human).right_arm
      end
    end

    context 'when adding new services to the original container' do
      let!(:duplicate) { container.dup }

      subject { -> { duplicate.get(:logger) } }

      before do
        container.set(:logger) { |s| s.instance 'MyLogger' }
      end

      it { is_expected.to raise_error Dumpling::Errors::Container::Missing }
    end

    context 'when adding new services to the duplicated container' do
      let(:duplicate) { container.dup }

      subject { -> { container.get(:logger) } }

      before do
        duplicate.set(:logger) { |s| s.instance 'MyLogger' }
      end

      it { is_expected.to raise_error Dumpling::Errors::Container::Missing }
    end
  end

  describe '#inspect' do
    subject { container.inspect }

    context 'when container is empty' do
      it { is_expected.to eq container.to_s }
    end

    context 'when container has multiple services' do
      let(:repository_class) do
        Class.new do
          def self.inspect
            'MegaClass'
          end
        end
      end
      let(:expected_string) do
        <<-INSPECT.strip
#{container}
apple
 --> instance: "apple"
 --> dependencies: repository
repository
 --> class: MegaClass
        INSPECT
      end

      before do
        repository_class = self.repository_class

        container.set :repository do |s|
          s.class repository_class
        end

        container.set :apple do |s|
          s.instance 'apple'
          s.dependency :repository
        end
      end

      it { is_expected.to eq expected_string }
    end
  end
end
