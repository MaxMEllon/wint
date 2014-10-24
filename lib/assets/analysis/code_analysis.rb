
class CodeAnalysis
  VERSION = 1.0

  def initialize(path)
    data = ModelHelper.decode_json(File.read(path))
    @ver = data[:ver].to_f
    @base = data[:base]
  end

  def update
    return unless @ver < VERSION
    @ver = VERSION
  end

  def self.create(data_dir, source_file)
    Dir::mkdir(data_dir)
    CodeAnalysis.comcut(source_file, "#{data_dir}/comcut.c")
    (data_dir + "/code.json").tap do |path|
      File.open(path, "w") do |f|
        f.puts ModelHelper.encode_json({ver: 0.0, base: "#{data_dir}/comcut.c"})
      end
    end
  end

  private
  def self.comcut(source_file, base)
    File.open(base, "w") do |f|
      f.puts File.read(source_file).gsub("#include", "hogefoobar")
    end
    comcut = `gcc -E -P #{base}`.split(/\r\n|\n/)
    File.open(base, "w") do |f|
      comcut.each do |line|
        next if line =~ /hogefoobar/
        f.puts line
      end
    end
  end
end


