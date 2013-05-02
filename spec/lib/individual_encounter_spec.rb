require 'individual_encounter'

describe IndividualEncounter do

  subject(:encounter) { IndividualEncounter.new(:measure_year => 2012, :measure_number => 1, :provider_id => 99) }

  describe '#new' do

    it 'has a measure_year' do
      expect(encounter.measure_year).to eq 2012
    end

    it 'has a measure_number' do
      expect(encounter.measure_number).to eq 1
    end

    it 'has a provider_id' do
      expect(encounter.provider_id).to eq 99
    end

  end

  describe 'denominator_answers' do

    it 'can set a service date' do
      encounter.denominator_answers[:service_date] = Date.parse('2012-01-01')
      expect(encounter.denominator_answers[:service_date].year).to eq 2012
    end

    it 'can set a fee for service boolean' do
      encounter.denominator_answers[:patient_is_fee_for_service] = true
      expect(encounter.denominator_answers[:patient_is_fee_for_service]).to eq true
    end

    it 'can set patient age' do
      encounter.denominator_answers[:patient_age] = 25
      expect(encounter.denominator_answers[:patient_age]).to eq 25
    end

    it 'can set an ICD9 code' do
      encounter.denominator_answers[:icd9] = '250.00'
      expect(encounter.denominator_answers[:icd9]).to eq '250.00'
    end

    it 'can set an CPT2 code' do
      encounter.denominator_answers[:cpt2] = '98765'
      expect(encounter.denominator_answers[:cpt2]).to eq '98765'
    end

  end

  describe 'numerator_answers' do

    it 'can set q1 float answer' do
      encounter.numerator_answers[:q1] = 9.1
      expect(encounter.numerator_answers[:q1]).to eq 9.1
    end

    it 'can set q2 boolean answer' do
      encounter.numerator_answers[:q2] = true
      expect(encounter.numerator_answers[:q2]).to eq true
    end

    it 'can set q3 string answer' do
      encounter.numerator_answers[:q3] = 'Not performed for medical reasons'
      expect(encounter.numerator_answers[:q3]).to eq 'Not performed for medical reasons'
    end

  end

  describe '.eligible?' do
    # return true if denominator validation passes
  end

  describe '.performance' do
    # return numerator validation status (:met, :excluded, :notmet)
  end

end