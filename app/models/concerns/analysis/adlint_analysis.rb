class AdlintAnalysis
  def initialize(analysis_path)
    @path = analysis_path + '/adlint'
    @adlint_file_path = @path + '/adlint.c'
    @adlint_metrix_path = @path + '/output/adlint.c.met.csv'
  end

  def analyze_func_num
    functions.values.count
  end

  def analyze_abc_size
    value = functions.values.map(&:abc_size).inject(0) { |sum, v| sum + v**2 }
    Math.sqrt(value / analyze_func_num)
  end

  def analyze_statement
    functions.values.map(&:statement).inject(:+)
  end

  def functions
    return @functions if @functions

    @functions = { 'global' => AdlintFunction.global }
    file_data = File.read(@adlint_file_path).split(/\r\n|\n/)
    data = File.read(@adlint_metrix_path).split(/\r\n|\n/)

    data.each do |line|
      next unless line =~ /^(DEF|MET|ASN|INI)/
      e = CSV.parse(line).first
      if e.first == 'DEF' && e[4] == 'F'
        name = e[7]
        start_line = e[2].to_i - 1
        end_line = start_line + e[9].to_i
        @functions[name] = AdlintFunction.new(name, start_line)
        @functions[name].add_text(file_data[start_line...end_line].join("\n"))
      elsif line =~ /^MET,FN/
        name = e[2]
        @functions[name].add_metrix(e[1], e[7].to_i)
      elsif line =~ /^(ASN|INI)/
        pos = e[2].to_i
        name = function_name(@functions.values, pos)
        @functions[name].add_assignment(pos, e[4], e[5])
      end
    end
    @functions
  end

  private

  def function_name(functions, position)
    functions.reverse_each do |function|
      return function.name if function.position < position
    end
    'global'
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

