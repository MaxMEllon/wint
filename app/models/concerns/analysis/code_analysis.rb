class CodeAnalysis
  def initialize(analysis_path)
    @path = analysis_path + '/code'
    @base_file_path = @path + '/comcut.c'
    @gzip_path = @path + '/comcut.gz'
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

