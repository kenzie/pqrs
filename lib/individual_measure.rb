class IndividualMeasure

  attr_accessor :year, :number, :slug, :denominator_validations, :denominator_fields, :numerator_validations, :numerator_fields

  def initialize(args = {})
    @year = args[:year].to_i
    @number = args[:number].to_i
    @slug = "individual-#{year}-#{number}".downcase
    @denominator_validations = {}
    @denominator_fields = {}
    @numerator_validations = {}
    @numerator_fields = {}
    parse_data_file
  end

  def self.find_by_slug(measure_slug)
    measure_slug = measure_slug.split('-')
    IndividualMeasure.new(:year => measure_slug[1], :number => measure_slug[2])
  end

  def self.find_by_year_and_number(year, number)
    IndividualMeasure.new(:year => year, :number => number)
  end

  def ==(msr)
    self.slug == msr.slug
  end

  def title(args=nil)
    return @title if args.nil?
    @title = args
  end

  def description(args=nil)
    return @description if args.nil?
    @description = args
  end

  def denominator_question(qid, args)
    self.denominator_fields[qid] = args
  end

  def numerator_question(qid, args)
    self.numerator_fields[qid] = args
  end

  def denominator_validation(type, &block)
    self.denominator_validations[type] = block
  end

  def numerator_validation(&block)
    self.numerator_validations = block
  end

  def validate_denominators(denominator_answers)
    denominator_validations.all? { |den| den.last.call(denominator_answers) == true }
  end

  def validate_numerators(numerator_answers)
    numerator_validations.call(numerator_answers)
  end

  def data_file_path
    "/Users/kenzie/Sites/pqrs/lib/patient360/measures/individual/#{year}/#{number}.rb".downcase
  end

  private

  def parse_data_file
    self.instance_eval(File.read(data_file_path))
  end

end