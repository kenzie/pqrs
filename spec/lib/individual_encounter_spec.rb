require 'individual_encounter'
require 'date'

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
      encounter.denominator_answers[:icd9_code] = '250.00'
      expect(encounter.denominator_answers[:icd9_code]).to eq '250.00'
    end

    it 'can set an CPT2 code' do
      encounter.denominator_answers[:cpt2_code] = '98765'
      expect(encounter.denominator_answers[:cpt2_code]).to eq '98765'
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

    it 'returns true if denominators all pass' do
      encounter.denominator_answers = {:service_date => Date.parse('2012-01-01'), :patient_is_fee_for_service => true, :patient_age => 25, :icd9_code => '250.00', :cpt2_code => '97802'}
      expect(encounter.eligible?).to eq true
    end

    it 'returns false if all denominators fail' do
      encounter.denominator_answers = {:service_date => Date.parse('2013-01-01'), :patient_is_fee_for_service => false, :patient_age => 12, :icd9_code => '150.00', :cpt2_code => '12345'}
      expect(encounter.eligible?).to eq false
    end

    it 'returns false if any denominator fails' do
      encounter.denominator_answers = {:service_date => Date.parse('2012-01-01'), :patient_is_fee_for_service => false, :patient_age => 25, :icd9_code => '250.00', :cpt2_code => '97802'}
      expect(encounter.eligible?).to eq false
    end

  end

  describe '.performance' do

    it 'returns :met if numerator passes (>9)' do
      encounter.numerator_answers = {:q1 => 9.1, :q2 => nil}
      expect(encounter.performance).to eq :pass
    end

    it 'returns :exclude if numerator is excluded (7..9)' do
      encounter.numerator_answers = {:q1 => 8.5, :q2 => nil}
      expect(encounter.performance).to eq :exclude
    end

    it 'returns :exclude if numerator is excluded (<7)' do
      encounter.numerator_answers = {:q1 => 6, :q2 => nil}
      expect(encounter.performance).to eq :exclude
    end

    it 'returns :fail if numerator fails' do
      encounter.numerator_answers = {:q1 => nil, :q2 => true}
      expect(encounter.performance).to eq :fail
    end

    it 'returns :incomplete if numerator is incomplete' do
      encounter.numerator_answers = {:q1 => nil, :q2 => nil}
      expect(encounter.performance).to eq :incomplete
    end

  end

  describe '.status' do

    it 'returns :ineligible if encounter.eligible? is false' do
      encounter.stub(:eligible?, false)
      expect(encounter.status).to eq :ineligible
    end

    it 'returns :eligible if encounter.eligible? is true but performance is :incomplete' do
      encounter.stub(:eligible? => true, :performance => :incomplete)
      expect(encounter.status).to eq :eligible
    end

    it 'returns :performance_met if encounter.eligible? is true and performance is :pass' do
      encounter.stub(:eligible? => true, :performance => :pass)
      expect(encounter.status).to eq :performance_met
    end

    it 'returns :performance_not_met if encounter.eligible? is true and performance is :fail' do
      encounter.stub(:eligible? => true, :performance => :fail)
      expect(encounter.status).to eq :performance_not_met
    end

    it 'returns :performance_excluded if encounter.eligible? is true and performance is :exclude' do
      encounter.stub(:eligible? => true, :performance => :exclude)
      expect(encounter.status).to eq :performance_excluded
    end

  end

end