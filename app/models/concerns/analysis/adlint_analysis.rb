class AdlintAnalysis
  def initialize(analysis_path)
    @path = analysis_path + '/adlint'
    @adlint_file_path = @path + '/adlint.c'
    @adlint_metrix_path = @path + '/output/adlint.c.met.csv'
  end

  def analyze_func_ref_strategy
    functions['strategy'].csub
  end

  def analyze_func_ref_max
    functions.values.map { |function| function.csub }.max
  end

  def analyze_func_ref_average
    functions.values.map { |function| function.csub }.inject(:+) / analyze_func_num
  end

  def analyze_line
    functions.values.map { |function| function.line }.inject(:+)
  end

  def analyze_func_num
    functions.values.count
  end

  def analyze_abc_size
    functions.values.map { |function| function.abc_size }.max
  end

  def analyze_statement
    functions.values.map { |function| function.statement }.inject(:+)
  end

  def functions
    return @functions if @functions

    @functions = split_functions_analysis
    data = File.read(@adlint_file_path).split(/\r\n|\n/)
    last_line = data.size - 1
    @functions.values.reverse_each do |function|
      line = function.position - 1
      function.add_text(data[line...last_line].join("\n"))
      last_line = line
    end

    @functions
  end

  private

  def split_functions_analysis
    func = {'global' => AdlintFunction.global }
    data = File.read(@adlint_metrix_path).split(/\r\n|\n/)
    data.each do |line|
      next unless line =~ /^(DEF|MET|ASN|INI)/
      e = str2arr(line)
      if e.first == 'DEF' && e[4] == 'F'
        name = e[7]
        func[name] = AdlintFunction.new(name, e[2].to_i)
      elsif line =~ /^MET,FN/
        name = e[2]
        func[name].add_metrix(e[1], e[7].to_i)
      elsif line =~ /^(ASN|INI)/
        pos = e[2].to_i
        name = function_name(func.values, pos)
        func[name].add_assignment(pos, e[4], e[5])
      end
    end
    func
  end

  def function_name(functions, position)
    functions.reverse_each do |function|
      return function.name if function.position < position
    end
    'global'
  end

  # @str    => "DEF,../adlint.c,7,5,F,X,F,strategy,\"int strategy(int,(int const)[],int)\",4"
  # @return => ["DEF","../adlint.c","7","5","F","X","F","strategy",
  #             "int strategy(int,(int const)[],int)","4"]
  def str2arr(str)
    a, b, c = str.split(/\"/)
    return str.split(',') if b.nil?
    return a.split(',') << b if c.nil?
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

