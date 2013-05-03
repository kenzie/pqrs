require 'individual_measure'

class IndividualEncounter

  attr_reader :measure_year, :measure_number, :provider_id
  attr_accessor :denominator_answers, :numerator_answers

  def initialize(opts = {})
    @measure_year = opts[:measure_year]
    @measure_number = opts[:measure_number]
    @provider_id = opts[:provider_id]
    @denominator_answers = {}
    @numerator_answers = {}
  end

  def measure
    IndividualMeasure.find_by_year_and_number(@measure_year, @measure_number)
  end

  def eligible?
    measure.validate_denominators(self.denominator_answers)
  end

end