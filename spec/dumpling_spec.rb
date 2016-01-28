require 'spec_helper'

describe Dumpling do
  it 'has a version number' do
    expect(Dumpling::Version::STRING).not_to be_nil
  end
end
