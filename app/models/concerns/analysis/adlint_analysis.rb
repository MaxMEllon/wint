class AdlintAnalysis
  def initialize(analysis_path)
    @path = analysis_path + '/adlint'
    @adlint_metrix_path = @path + '/output/adlint.c.met.csv'
  end

  def analyze_func_ref_strategy
    records.metrix_csub.find { |m| m.function_name == 'strategy' }.value
  end

  def analyze_func_ref_max
    records.metrix_csub.map(&:value).max
  end

  def analyze_func_ref_average
    records.metrix_csub.map(&:value).inject(:+) / analyze_func_num
  end

  def analyze_line
    records.metrix_line.map(&:value).inject(:+)
  end

  def analyze_func_num
    records.functions.count
  end

  private

  def records
    return @records if @records
    @records = Records.new

    data = File.read(@adlint_metrix_path).split(/\r\n|\n/)
    data.each do |line|
      next unless line =~ /^(DEF|MET)/
      e = str2arr(line)
      if e.first == 'DEF' && e[4] == 'F'
        @records.add AdlintDefinition.new(e[0], e[4], e[7])
      elsif line =~ /^MET,FN/
        @records.add AdlintMetrix.new(e[0], e[1], e[2], e[7].to_i)
      end
    end

    @records
  end

  # @str    => "DEF,../adlint.c,7,5,F,X,F,strategy,\"int strategy(int,(int const)[],int)\",4"
  # @return => ["DEF","../adlint.c","7","5","F","X","F","strategy",
  #             "int strategy(int,(int const)[],int)","4"]
  def str2arr(str)
    a, b, c = str.split(/\"/)
    return str.split(',') if b.nil?
    elem = c.split(',')
    elem[0] = b
    a.split(',') + elem
  end

  public_class_method

  def self.create(analysis_path, content)
    path = analysis_path + '/adlint'
    Dir.mkdir(path)

    content.gsub!(/#include/, '// #include')
    File.write(path + '/adlint.c', content)
    Rake.sh "cd #{path} && adlintize -o output && cd #{path}/output && make verbose-all"

    new(analysis_path)
  end
end

