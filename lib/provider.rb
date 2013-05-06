class Provider

  attr_reader :name, :npi, :tin, :measure_preference, :organization_id

  def initialize(args = {})
    @name = args[:name]
    @npi = args[:npi]
    @tin = args[:tin]
    @measure_preference = args[:measure_preference]
    @organization_id = args[:organization_id]
  end

end