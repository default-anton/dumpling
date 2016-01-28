require 'spec_helper'

describe Dumpling::Container do
  let(:instance) { described_class.new }
  let(:chickens_repository) { Class.new }
  let(:dogs_repository) { Class.new }
  let(:eat_chickens) do
    Class.new { attr_accessor :chickens_repository, :dogs_repository }
  end

  describe '#set' do
    describe 'validation' do
      let(:error) { Dumpling::Errors::Specification::Invalid }

      describe 'valid items' do
        subject do
          proc do
            instance.set :bart do |c|
              c.class String
            end

            instance.set :simpson do |c|
              c.instance 'Simpson'
            end

            instance.set :item do |c|
              c.class String
              c.inject 'bart'
            end
          end
        end

        it { is_expected.not_to raise_error }
      end

      context 'when both the class and instance attributes are not defined' do
        subject do
          -> { instance.set(:item) {} }
        end

        it { is_expected.to raise_error error, 'You must define #class or #instance' }
      end

      context 'when specified dependencies do not exist' do
        let(:error) { Dumpling::Errors::Specification::MissingDependencies }

        subject do
          proc do
            instance.set :item do |c|
              c.class String
              c.inject 'bart'
              c.inject 'simpson'
            end
          end
        end

        context 'when all dependencies are not defined' do
          it { is_expected.to raise_error error, 'bart, simpson' }
        end

        context 'when just one dependency is not defined' do
          before do
            instance.set(:bart) { |c| c.class String }
          end

          it { is_expected.to raise_error error, 'simpson' }
        end
      end

      context 'when trying to define an item twice' do
        let(:error) { Dumpling::Errors::Container::Duplicate }

        subject do
          proc do
            instance.set :simpson do |c|
              c.instance 'Simpson'
            end

            instance.set :simpson do |c|
              c.instance 'Simpson'
            end
          end
        end

        it { is_expected.to raise_error error, 'simpson' }
      end

      context 'when registering an instance of an object' do
        let(:command) { Class.new }
        let(:command_instance) { command.new }

        before do
          instance.set :do do |c|
            c.instance command_instance
          end
        end

        subject { instance[:do] }

        it 'does not instantiate an object' do
          expect(subject).to eq command_instance
        end
      end
    end
  end

  describe '#get' do
    context 'when an item does not exist' do
      let(:error) { Dumpling::Errors::Container::Missing }

      subject { -> { instance[:unnamed] } }

      it { is_expected.to raise_error error, 'unnamed' }
    end

    describe 'an item without dependencies' do
      let!(:configuration) do
        chickens_repository = self.chickens_repository

        instance.configure do
          set :'adapters.chickens_repository' do |c|
            c.class chickens_repository
          end
        end
      end

      subject { instance[:'adapters.chickens_repository'] }

      it { is_expected.to be_an_instance_of chickens_repository }
    end

    describe 'an item with dependencies' do
      let(:chickens_repository_instance) { chickens_repository.new }

      before do
        chickens_repository_instance = self.chickens_repository_instance
        dogs_repository = self.dogs_repository
        eat_chickens = self.eat_chickens

        instance.configure do
          set :'adapters.chickens_repository' do |c|
            c.instance chickens_repository_instance
          end

          set :'adapters.dogs_repository' do |c|
            c.class dogs_repository
          end

          set :'commands.eat_chickens' do |c|
            c.class eat_chickens
            c.inject 'adapters.chickens_repository'
            c.inject 'adapters.dogs_repository'
          end
        end
      end

      subject { instance[:'commands.eat_chickens'] }

      it { is_expected.to be_an_instance_of eat_chickens }

      describe 'dependencies' do
        it { expect(subject.chickens_repository).to eq chickens_repository_instance }
        it { expect(subject.dogs_repository).to be_an_instance_of dogs_repository }
      end
    end

    describe 'an item with dependencies which, in turn, have their own dependencies' do
      let(:dogs_repository) { Class.new { attr_accessor :chickens_repository } }

      before do
        chickens_repository = self.chickens_repository
        dogs_repository = self.dogs_repository
        eat_chickens = self.eat_chickens

        instance.configure do
          set :'adapters.chickens_repository' do |c|
            c.class chickens_repository
          end

          set :'adapters.dogs_repository' do |c|
            c.class dogs_repository
            c.inject 'adapters.chickens_repository'
          end

          set :'commands.eat_chickens' do |c|
            c.class eat_chickens
            c.inject 'adapters.dogs_repository'
          end
        end
      end

      subject { instance[:'commands.eat_chickens'] }

      it { is_expected.to be_an_instance_of eat_chickens }

      describe 'dependencies' do
        it { expect(subject.dogs_repository).to be_an_instance_of dogs_repository }

        describe 'nested dependency' do
          subject { instance[:'commands.eat_chickens'].dogs_repository }

          it { expect(subject.chickens_repository).to be_an_instance_of chickens_repository }
        end
      end
    end
  end
end
