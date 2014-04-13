class Platform
  attr_accessor :name
  attr_accessor :artifacts_path
  attr_accessor :environments

  def initialize(yml)
    @name =  yml.fetch("name")
    @artifacts_path = yml.fetch("artifacts")
    @environments = yml.fetch("environments")
  end

  def health
    puts @name
  end

end