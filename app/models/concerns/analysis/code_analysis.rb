class CodeAnalysis
  def initialize(analysis_path)
    @path = analysis_path + '/code'
    @base_file_path = @path + '/comcut.c'
    @cflow_path = @path + '/cflow.dat'
    @gzip_path = @path + '/comcut.gz'
    @func_ref_path = @path + '/func_ref.csv'
  end

  def analyze_line
    File.read(@base_file_path).split(/\r\n|\n/).size
  end

  def analyze_size
    File.stat(@base_file_path).size
  end

  def analyze_gzip_size
    `gzip -c -9 #{@base_file_path} > #{@gzip_path}`
    File.stat(@gzip_path).size
  end

  def analyze_count_if
    File.read(@base_file_path).count('if')
  end

  def analyze_count_loop
    File.read(@base_file_path).count('for') + File.read(@base_file_path).count('while')
  end

  def analyze_func_num
    # 一番上の行は要らない。strategyはカウントしない
    File.read(@func_ref_path).split(/\r\n|\n/).size - 2
  end

  def analyze_func_ref
    `cflow --omit-symbol-names --omit-arguments #{@base_file_path} > #{@cflow_path}`
    reference = {}
    key = ''
    File.read(@cflow_path).split(/\r\n|\n/).each do |line|
      if line =~ /^([^\s]*?)\(\)\s/
        key = Regexp.last_match(1)
        reference[key] = []
      elsif line =~ /^\s\s\s\s([^\s]*?)\(\)\s/
        reference[key] << Regexp.last_match(1)
      end
    end
    matrix = reference_to_matrix(reference)
    File.write(@func_ref_path, matrix.join("\n"))
    amount_func_ref(matrix)
  end

  private

  def reference_to_matrix(reference)
    methods = (reference.keys + reference.values).flatten.uniq
    methods.unshift(methods.delete('strategy')) # strategyを一番前へ
    matrix = [',' + methods.join(',')]
    methods.each do |method|
      arr = [method]
      methods.size.times { arr << 0 }
      unless reference[method].blank?
        reference[method].each do |value|
          id = methods.index(value) + 1
          arr[id] = 1
        end
      end
      arr << arr.slice(1..-1).inject { |s, n| s + n }
      matrix << arr.join(',')
    end
    matrix
  end

  def amount_func_ref(data)
    data.shift # 要らないので削除
    amounts = data.map { |d| d.split(',').last.to_i }
    {
      strategy: amounts.first, # strategy() が一番先頭のはずなので
      max: amounts.max,
      average: ('%.2f' % (amounts.inject { |s, n| s + n } / data.size.to_f)).to_f
    }
  end

  public_class_method

  def self.create(analysis_path, content)
    path = analysis_path + '/code'
    Dir.mkdir(path)

    content = content.split(/\r\n|\n/).delete_if { |line| line =~ /^#include/ }
    comcut_path = path + '/comcut.c'
    File.write(comcut_path, content.join("\n"))
    comcut_content = `gcc -E -P #{comcut_path}`.split(/\r\n|\n/)
    File.write(comcut_path, comcut_content.join("\n"))

    new(analysis_path)
  end
end

