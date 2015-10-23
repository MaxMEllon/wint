class CodeAnalysis
  attr_reader :count, :line, :size, :gzip_size, :func_ref, :func_num

  VERSION = 1.0

  def initialize(attributes = {})
    data = ModelHelper.decode_json(File.read(attributes[:path]))
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

  def to_csv
    [@line, @size, @gzip_size, @count[:if], @count[:loop], @func_ref[:strategy], @func_ref[:max], @func_ref[:average], @func_num].join(",")
  end

  def self.to_csv_header
    %w(行数 ファイルサイズ 圧縮ファイルサイズ ifの条件の数 loopの数 strategy関数からの呼出回数 最多呼出回数 平均呼出回数 関数の定義数).join(",")
  end

  def self.create(data_dir, code)
    path = data_dir + '/code'
    comcut = MyFile.new(
      path: "#{path}/comcut.c",
      data: code.data.gsub("#include", "hogefoobar")
    )

    comcut.write
    comcut_data = `gcc -E -P #{comcut.path}`.split(/\r\n|\n/)
    File.open(comcut.path, "w") do |f|
      comcut_data.each do |line|
        next if line =~ /hogefoobar/
        f.puts line
      end
    end

    data = ModelHelper.encode_json({ver: 0.0, base_path: comcut.path})
    json = MyFile.new(path: path + '/code.json', data: data)
    json.write
    json.path
  end

  private

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

