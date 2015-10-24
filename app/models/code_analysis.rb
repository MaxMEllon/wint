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
    @gzip_path = create_gzip

    @function = FunctionAnalysis.new(MyFile.new(path: @cflow_path))
    @func_ref_path = @function.func_ref_path

    @syntax = SyntaxAnalysis.new(MyFile.new(path: @base_path))

    @count = @syntax.count_all_word
    @line = File.read(@base_path).split(/\r\n|\n/).size
    @size = File.stat(@base_path).size
    @gzip_size = File.stat(@gzip_path).size
    @func_ref = @function.amount_func_ref
    @func_num = File.read(@func_ref_path).split(/\r\n|\n/).size - 2 # 一番上の行は要らない。strategyはカウントしない
  end

  def to_csv
    [@line, @size, @gzip_size, @count[:if], @count[:loop], @func_ref[:strategy], @func_ref[:max], @func_ref[:average], @func_num].join(",")
  end

  def self.to_csv_header
    %w(行数 ファイルサイズ 圧縮ファイルサイズ ifの条件の数 loopの数 strategy関数からの呼出回数 最多呼出回数 平均呼出回数 関数の定義数).join(",")
  end

  def self.create(data_dir, data)
    path = data_dir + '/code'
    comcut = MyFile.new(
      path: "#{path}/comcut.c",
      data: data.gsub("#include", "hogefoobar")
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

  def create_gzip
    @base_path.sub(/comcut.c/, "comcut.gz").tap do |path|
      `gzip -c -9 #{@base_path} > #{path}`
    end
  end
end

