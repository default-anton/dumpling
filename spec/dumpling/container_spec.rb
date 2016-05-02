require 'spec_helper'

describe Dumpling::Container do
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
end
