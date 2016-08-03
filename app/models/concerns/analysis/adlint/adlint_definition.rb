class AdlintDefinition < AdlintRecordBase
  attr_reader :definition_type

  def initialize(type, dtype, fname)
    @type = type
    @definition_type = dtype
    @function_name = fname
  end

  def function?
    @definition_type == 'F'
  end
end

