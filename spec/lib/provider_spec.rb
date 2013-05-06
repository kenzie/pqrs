require 'provider'

describe Provider do

  subject(:provider) { Provider.new(:name => 'Dr. Michael Smith', :npi => '123456789', :tin => '1234567890', :measure_preference => 'individual', :organization_id => 99) }

  describe '#new' do

    it 'has a name' do
      expect(provider.name).to eq 'Dr. Michael Smith'
    end

    it 'has a npi' do
      expect(provider.npi).to eq '123456789'
    end

    it 'has a tin' do
      expect(provider.tin).to eq '1234567890'
    end

    it 'has a measure_preference' do
      expect(provider.measure_preference).to eq 'individual'
    end

    it 'has an organization_id' do
      expect(provider.organization_id).to eq 99
    end

  end

end