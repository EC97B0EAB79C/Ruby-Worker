class Data
  attr_reader :id, :name, :type

  def initialize(data)
    @id = data["id"]
    @name = data["name"]
    @type = data["type"]
  end
end
