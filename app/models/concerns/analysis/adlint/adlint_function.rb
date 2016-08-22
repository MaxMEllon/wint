class AdlintFunction
  attr_reader :name, :position, :text, :metrix, :assignment

  def initialize(name, position)
    @name = name
    @position = position
    @text = ''
    @metrix = {}
    @assignment = []
  end

  def add_metrix(type, value)
    @metrix[type] = value
  end

  def add_assignment(pos, to, from)
    @assignment << [pos, to, from]
  end

  def add_text(text)
    @text = text
  end

  def csub
    @metrix['FN_CSUB'] || 0
  end

  def line
    @metrix['FN_LINE'] || 0
  end

  def statement
    @metrix['FN_STMT'] || 0
  end

  def abc_size
    return 0 if @name == 'global'
    a = @assignment.count
    b = @metrix['FN_CSUB']
    c = @text.gsub(/&&/, 'and').gsub(/\|\|/, 'or')
             .scan(/\s(if|while|for|case|and|or)/).count
    Math.sqrt(a**2 + b**2 + c**2)
  end

  public_class_method

  def self.global
    new('global', 0)
  end
end

