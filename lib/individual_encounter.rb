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
    measure.valid_denominators?(self.denominator_answers)
  end

  def performance
    # :incomplete if submitted numerator answers can't be used to calculate numerator status
    perf = measure.validate_numerators(self.numerator_answers)
    perf.nil? ? :incomplete : perf.last
  end

  def status
    return :performance_excluded if eligible? && performance == :exclude
    return :performance_not_met if eligible? && performance == :fail
    return :performance_met if eligible? && performance == :pass
    return :eligible if eligible?
    :ineligible
  end

end