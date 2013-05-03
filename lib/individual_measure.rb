class IndividualMeasure

  attr_reader :year, :number, :slug, :denominator_validations, :denominator_fields, :numerator_fields
  attr_accessor :numerator_validations

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

  def icd9_code(codes)
    denominator_question(:icd9_code, :label => 'ICD-9 Code', :collection => codes)
    denominator_validation :icd9_code do |answers|
      next {:pass => true} if codes.include? answers[:icd9_code]
      {:pass => false, :reason => "Patient must have one of the available ICD-9 codes."}
    end
  end

  def cpt2_code(codes)
    denominator_question(:cpt2_code, :label => 'CPT-II Code', :collection => codes)
    denominator_validation :cpt2_code do |answers|
      next {:pass => true} if codes.include? answers[:cpt2_code]
      {:pass => false, :reason => "Patient must have one of the available CPT-II codes."}
    end
  end

  def patient_age_between(left,right)
    denominator_validation :patient_age do |answers|
      next {:pass => true} if (left..right).cover? answers[:patient_age]
      {:pass => false, :reason => "Patient was not between #{left} and #{right} years of age during the year of encounter."}
    end
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
    validations = {}
    denominator_validations.each do |key,den|
      validations[key] = den.call(denominator_answers)
    end
    validations
  end

  def validate_numerators(numerator_answers)
    numerator_validations.call(numerator_answers)
  end

  def valid_denominators?(denominator_answers)
    validate_denominators(denominator_answers).all? {|den| den.last[:pass] == true }
  end

  def data_file_path
    "/Users/kenzie/Sites/pqrs/lib/patient360/measures/individual/#{year}/#{number}.rb".downcase
  end

  private

  def parse_data_file
    self.instance_eval(File.read(data_file_path))
  end

end