class AdlintMetrix < AdlintRecordBase
  attr_reader :metrix_type, :value

  def initialize(type, mtype, fname, value)
    @type = type + '_FN'
    @metrix_type = mtype
    @function_name = fname
    @value = value
  end

  def metrix?
    @type == 'MET_FN'
  end
end

