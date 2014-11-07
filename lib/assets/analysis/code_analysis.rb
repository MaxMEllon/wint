
class CodeAnalysis
  attr_reader :count, :line, :size, :func_ref, :func_num

  VERSION = 2.0

  def initialize(path)
    data = ModelHelper.decode_json(File.read(path))
    @ver = data[:ver].to_f
    @base_path = data[:base_path]
    @cflow_path = data[:cflow_path]
    @func_ref_path = data[:func_ref_path]
    @gzip_path = data[:gzip_path]

    @count = data[:count]
    @line = data[:line]
    @size = data[:size]
    @gzip_size = data[:gzip_size]
    @func_ref = data[:func_ref]
    @func_num = data[:func_num]
  end

  def latest?
    @ver >= VERSION
  end

  def update
    return if self.latest?
    @ver = VERSION
    @cflow_path = create_cflow
    @func_ref_path = create_func_ref
    @gzip_path = create_gzip

    @count = { loop: count_word("for") + count_word("while"), if: count_if }
    @line = File.read(@base_path).split(/\r\n|\n/).size
    @size = File.stat(@base_path).size
    @gzip_size = File.stat(@gzip_path).size
    @func_ref = amount_func_ref
    @func_num = File.read(@func_ref_path).split(/\r\n|\n/).size - 2 # 一番上の行は要らない。strategyはカウントしない
  end

  def self.create(data_dir, source_file)
    Dir::mkdir(data_dir)
    CodeAnalysis.create_base(source_file, "#{data_dir}/comcut.c")
    (data_dir + "/code.json").tap do |path|
      File.open(path, "w") do |f|
        f.puts ModelHelper.encode_json({ver: 0.0, base_path: "#{data_dir}/comcut.c"})
      end
    end
  end

  private
  def self.create_base(source_file, base_path)
    File.open(base_path, "w") do |f|
      f.puts File.read(source_file).gsub("#include", "hogefoobar")
    end
    comcut = `gcc -E -P #{base_path}`.split(/\r\n|\n/)
    File.open(base_path, "w") do |f|
      comcut.each do |line|
        next if line =~ /hogefoobar/
        f.puts line
      end
    end
  end

  def create_cflow
    @base_path.sub(/comcut.c/, "cflow.dat").tap do |path|
      File.open(path, "w") do |f|
        f.puts `cflow --omit-symbol-names --omit-arguments #{@base_path}`
      end
    end
  end

  def create_func_ref
    reference = get_reference
    @base_path.sub(/comcut.c/, "func_ref.csv").tap do |path|
      File.open(path, "w") { |f| f.puts reference_to_matrix(reference) }
    end
  end

  def create_gzip
    @base_path.sub(/comcut.c/, "comcut.gz").tap do |path|
      `gzip -c -9 #{@base_path} > #{path}`
    end
  end

  def get_reference
    reference = {}
    key = ""
    File.read(@cflow_path).split(/\r\n|\n/).each do |line|
      if line =~ /^([^\s]*?)\(\)\s/
        key = $1
        reference[key] = []
      elsif line =~ /^\s\s\s\s([^\s]*?)\(\)\s/
        reference[key] << $1
      end
    end
    reference
  end

  def reference_to_matrix(reference)
    methods = (reference.keys + reference.values).flatten.uniq
    methods.unshift(methods.delete("strategy"))  # strategyを一番前へ
    matrix = ["," + methods.join(",")]
    methods.each do |method|
      arr = [method]
      methods.size.times {arr << 0}
      unless reference[method].blank?
        reference[method].each do |value|
          id = methods.index(value) + 1
          arr[id] = 1
        end
      end
      arr << arr.slice(1..-1).inject {|s, n| s + n}
      matrix << arr.join(",")
    end
    matrix
  end

  def count_word(word)
    count = 0
    File.read(@base_path).split(/\r\n|\n/).each do |line|
      count += 1 if line =~ /(\t|\s)#{word}(\t|\s)*\(/
    end
    count
  end

  def count_if
    count = 0
    File.read(@base_path).split(/\r\n|\n/).each do |line|
      count += 1 if line =~ /(\t|\s)if(\t|\s)*\(/
      count += 1 if line =~ /(&&|\|\|)/
    end
    count
  end

  def amount_func_ref
    data = File.read(@func_ref_path).split(/\r\n|\n/)
    data.shift  # 要らないので削除
    amounts = data.map {|d| d.split(",").last.to_i}
    {
      strategy: amounts.first,  # strategy() が一番先頭のはずなので
      max: amounts.max,
      average: ("%.2f" % (amounts.inject {|s, n| s + n} / data.size.to_f)).to_f
    }
  end
end

