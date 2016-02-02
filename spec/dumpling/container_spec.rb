require 'spec_helper'

describe Dumpling::Container do
  let(:container) { described_class.new }

  describe '#set' do
    context 'when the specification is valid' do
      let(:repository_class) { Class.new }
      let!(:definition) do
        repository_class = self.repository_class

        container.set :repository do |s|
          s.class repository_class
        end
      end

      subject { definition }

      it { is_expected.to eq :repository }

      describe '#get' do
        subject { container.get(:repository) }

        it { is_expected.to be_an_instance_of repository_class }
      end
    end

    context 'when the specification is invalid' do
      subject do
        container.set :repository do
        end
      end

      it 'does not set the invalid id' do
        expect { subject }.to raise_error Dumpling::Errors::Specification::Invalid
        expect { container.get(:repository) }.to raise_error Dumpling::Errors::Container::Missing
      end
    end

    context 'when the id is duplicated' do
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

      it 'does not overwrite the id' do
        expect { subject }.to raise_error Dumpling::Errors::Container::Duplicate
        expect(container.get(:repository)).to be_an_instance_of repository_class
      end
    end
  end

  describe '#get' do
    context 'when the id exists' do
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

    context 'when the id does not exist' do
      subject { -> { container.get(:repository) } }

      it { is_expected.to raise_error Dumpling::Errors::Container::Missing }
    end

    context 'when the specification is configured to use an instance' do
      before do
        container.set :string do |s|
          s.instance 'instance'
        end
      end

      subject { container.get(:string) }

      it { is_expected.to eq 'instance' }
    end

    context 'when the id has dependencies' do
      describe 'multiple dependencies' do
        let(:repository_instance) do
          klass = Class.new { attr_accessor :first_string, :second_string }
          klass.new
        end

        before do
          repository_instance = self.repository_instance

          container.configure do
            set :first_string do |s|
              s.instance 'string1'
            end

            set :second_string do |s|
              s.instance 'string2'
            end

            set :repository do |s|
              s.instance repository_instance
              s.dependency :first_string
              s.dependency :second_string
            end
          end
        end

        subject { container.get(:repository) }

        it { is_expected.to eq repository_instance }

        describe 'dependencies' do
          subject { [super().first_string, super().second_string] }

          it { is_expected.to eq %w(string1 string2) }
        end
      end

      describe 'nested dependencies' do
        let(:logger_class) { Class.new }
        let(:adapter_instance) do
          klass = Class.new { attr_accessor :logger }
          klass.new
        end
        let(:repository_instance) do
          klass = Class.new { attr_accessor :adapter }
          klass.new
        end

        before do
          logger_class = self.logger_class
          adapter_instance = self.adapter_instance
          repository_instance = self.repository_instance

          container.configure do
            set :logger do |s|
              s.class logger_class
            end

            set :adapter do |s|
              s.instance adapter_instance
              s.dependency :logger
            end

            set :repository do |s|
              s.instance repository_instance
              s.dependency :adapter
            end
          end
        end

        subject { container.get(:repository) }

        it { is_expected.to eq repository_instance }

        describe 'top tier dependency' do
          subject { super().adapter }

          it { is_expected.to eq adapter_instance }
        end

        describe 'the lower tier dependency' do
          subject { super().adapter.logger }

          it { is_expected.to be_an_instance_of logger_class }
        end
      end

      context 'when the dependency is defined by a private attr_accessor' do
        let(:repository_instance) do
          klass = Class.new do
            attr_accessor :symbol
            private :symbol, :symbol=
          end
          klass.new
        end

        before do
          repository_instance = self.repository_instance

          container.configure do
            set :symbol do |s|
              s.instance :strong_symbol
            end

            set :repository do |s|
              s.instance repository_instance
              s.dependency :symbol
            end
          end
        end

        subject { container.get(:repository) }

        it { is_expected.to eq repository_instance }

        describe 'dependency' do
          subject { super().send(:symbol) }

          it { is_expected.to eq :strong_symbol }
        end
      end
    end
  end
end
