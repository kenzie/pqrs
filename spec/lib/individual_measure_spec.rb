require 'individual_measure'
require 'date'

describe IndividualMeasure do

  subject(:measure) { IndividualMeasure.new(:year => 2012, :number => 1) }

  describe '#new' do

    it "has a measure year" do
      expect(measure.year).to eq 2012
    end

    it "has a measure number" do
      expect(measure.number).to eq 1
    end

    it "has a measure slug" do
      expect(measure.slug).to eq 'individual-2012-1'
    end

    it "has a data file path" do
      expect(measure.data_file_path).to match 'lib/patient360/measures/individual/2012/1.rb'
    end

    context "data file loading" do

      it "sets a title" do
        expect(measure.title).to eq "Diabetes Mellitus: Hemoglobin A1c Poor Control in Diabetes Mellitus"
      end

      it "sets a description" do
        expect(measure.description).to eq "Percentage of patients aged 18 through 75 years with diabetes mellitus who had most recent hemoglobin A1c greater than 9.0%"
      end

      it "defines a denominator age validation" do
        expect(measure.denominator_validations[:patient_age].class).to eq Proc
      end

      it "defines a denominator ffs validation" do
        expect(measure.denominator_validations[:patient_is_fee_for_service].class).to eq Proc
      end

      it "defines a numerator validation" do
        expect(measure.numerator_validations.class).to eq Proc
      end

    end

  end

  describe '#find_by_slug' do

    it "creates a Measure from a slug" do
      expect(IndividualMeasure.find_by_slug('individual-2012-1')).to eq measure
    end

  end

  describe '#find_by_year_and_number' do

    it "creates a Measure from a year and number" do
      expect(IndividualMeasure.find_by_year_and_number(2012, 1)).to eq measure
    end

  end

  context 'denominator_fields' do

    it 'has 2 questions' do
      expect(measure.denominator_fields.size).to eq 2
    end

    it 'has question 1' do
      expect(measure.denominator_fields[:icd9_code]).to eq :label=>"ICD-9 Code", :collection=>["250.00", "250.01", "250.02", "250.03", "250.10", "250.11", "250.12", "250.13", "250.20", "250.21", "250.22", "250.23", "250.30", "250.31", "250.32", "250.33", "250.40", "250.41", "250.42", "250.43", "250.50", "250.51", "250.52", "250.53", "250.60", "250.61", "250.62", "250.63", "250.70", "250.71", "250.72", "250.73", "250.80", "250.81", "250.82", "250.83", "250.90", "250.91", "250.92", "250.93", "357.2", "362.01", "362.02", "362.03", "362.04", "362.05", "362.06", "362.07", "366.41", "648.00", "648.01", "648.02", "648.03", "648.04"]
    end

    it 'has question 2' do
      expect(measure.denominator_fields[:cpt2_code]).to eq :label=>"CPT-II Code", :collection=>["97802", "97803", "97804", "99201", "99202", "99203", "99204", "99205", "99212", "99213", "99214", "99215", "99304", "99305", "99306", "99307", "99308", "99309", "99310", "99324", "99325", "99326", "99327", "99328", "99334", "99335", "99336", "99337", "99341", "99342", "99343", "99344", "99345", "99347", "99348", "99349", "99350", "G0270", "G0271"]
    end

  end

  context 'numerator_fields' do

    it 'has 2 questions' do
      expect(measure.numerator_fields.size).to eq 2
    end

    it 'has question 1' do
      expect(measure.numerator_fields[:q1]).to eq :label => "Most recent Hemoglobin A1c level", :as => :numeric
    end

    it 'has question 2' do
      expect(measure.numerator_fields[:q2]).to eq :label => "Hemoglobin A1c test not performed?", :as => :boolean, :wrapper => :checkbox
    end

  end

  context 'validate_denominators' do

    it 'returns passing validations if denominators all pass' do
      denominator_answers = {:service_date => Date.parse('2012-01-01'), :patient_is_fee_for_service => true, :patient_age => 25, :icd9_code => '250.00', :cpt2_code => '97802'}
      expect(measure.validate_denominators(denominator_answers)).to eq :patient_is_fee_for_service => {:pass => true}, :patient_age => {:pass => true}
    end

    it 'returns failing validations with reasons if all denominators fail' do
      denominator_answers = {:service_date => Date.parse('2013-01-01'), :patient_is_fee_for_service => false, :patient_age => 12, :icd9_code => '150.00', :cpt2_code => '12345'}
      expect(measure.validate_denominators(denominator_answers)).to eq :patient_is_fee_for_service => {:pass => false, :reason => 'Patient must be Medicare Part B fee for service'}, :patient_age => {:pass => false, :reason => 'Patient must be between 18 and 75 years old at time of encounter'}
    end

    it 'returns a failing validation with reason if any denominator fails' do
      denominator_answers = {:service_date => Date.parse('2012-01-01'), :patient_is_fee_for_service => false, :patient_age => 25, :icd9_code => '250.00', :cpt2_code => '97802'}
      expect(measure.validate_denominators(denominator_answers)).to eq :patient_is_fee_for_service => {:pass => false, :reason => 'Patient must be Medicare Part B fee for service'}, :patient_age => {:pass => true}
    end

  end

  context 'valid_denominators?' do

    it 'returns true if all denominators are valid' do
      denominator_answers = {:service_date => Date.parse('2012-01-01'), :patient_is_fee_for_service => true, :patient_age => 25, :icd9_code => '250.00', :cpt2_code => '97802'}
      expect(measure.valid_denominators?(denominator_answers)).to eq true
    end

  end

  context 'validate_numerators' do

    it 'returns ["1234", :pass] if numerator passes (>9)' do
      numerator_answers = {:q1 => 9.1, :q2 => nil}
      expect(measure.validate_numerators(numerator_answers)).to eq ["1234F", :pass]
    end

    it 'returns ["1234F-2P", :exclude] if numerator is excluded (7..9)' do
      numerator_answers = {:q1 => 8.5, :q2 => nil}
      expect(measure.validate_numerators(numerator_answers)).to eq ["1234F-2P", :exclude]
    end

    it 'returns ["1234F-23", :exclude] if numerator is excluded (<7)' do
      numerator_answers = {:q1 => 6, :q2 => nil}
      expect(measure.validate_numerators(numerator_answers)).to eq ["1234F-3P", :exclude]
    end

    it 'returns ["1234F-8P", :fail] if numerator fails' do
      numerator_answers = {:q1 => nil, :q2 => true}
      expect(measure.validate_numerators(numerator_answers)).to eq ["1234F-8P", :fail]
    end

  end

end