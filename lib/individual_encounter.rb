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

end