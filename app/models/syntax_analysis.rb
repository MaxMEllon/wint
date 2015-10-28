class SyntaxAnalysis
  def initialize(comcut)
    @comcut = comcut
  end

  def count_all_word
    { loop: count_word("for") + count_word("while"), if: count_if }
  end

  def count_word(word)
    count = 0
    @comcut.data.split(/\r\n|\n/).each do |line|
      count += 1 if line =~ /(\t|\s)#{word}(\t|\s)*\(/
    end
    count
  end

  def count_if
    count = 0
    @comcut.data.split(/\r\n|\n/).each do |line|
      count += 1 if line =~ /(\t|\s)if(\t|\s)*\(/
      count += 1 if line =~ /(&&|\|\|)/
    end
    count
  end
end

