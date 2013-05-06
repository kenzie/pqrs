class Provider

  attr_reader :name, :npi, :tin, :measure_preference

  def initialize(args = {})
    @name = args[:name]
    @npi = args[:npi]
    @tin = args[:tin]
    @measure_preference = args[:measure_preference]
  end

end