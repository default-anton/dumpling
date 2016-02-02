require 'spec_helper'

describe Dumpling::Specification do
  let(:specification) { described_class.new }

  describe '#class' do
    let(:repository_class) { Class.new }

    subject { specification.class }

    it { is_expected.to be_nil }

    it 'sets the class' do
      specification.class repository_class
      expect(specification.class).to eq repository_class
    end
  end

  describe '#instance' do
    let(:repository_class) { Class.new }
    let(:repository_instance) { repository_class.new }

    subject { specification.instance }

    it { is_expected.to be_nil }

    it 'sets the instance' do
      specification.instance repository_instance
      expect(specification.instance).to eq repository_instance
    end
  end

  describe '#dependency' do
    subject { specification.dependencies }

    context 'there is no dependencies' do
      it { is_expected.to be_empty }
    end

    context 'when using a single-worded id' do
      before { specification.dependency(:users_repository) }

      it { is_expected.to eq [{ id: :users_repository, attribute: :users_repository }] }
    end

    context 'when using a composite id' do
      describe 'good delimiters' do
        before do
          specification.dependency(:'repo.ads')
          specification.dependency(:'repo:users')
          specification.dependency(:'repo legs')
        end

        it 'guesses the name of the attribute by the last word of the id' do
          expect(subject).to eq [
            { id: :'repo.ads', attribute: :ads },
            { id: :'repo:users', attribute: :users },
            { id: :'repo legs', attribute: :legs }
          ]
        end
      end

      describe 'bad delimiters' do
        before { specification.dependency(:repo_ads) }

        it 'does not guess the name by the last word if an underscore is a delimiter' do
          expect(subject).to eq [{ id: :repo_ads, attribute: :repo_ads }]
        end
      end
    end
  end
end
