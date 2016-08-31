class CodeAnalysis
  def initialize(analysis_path)
    @path = analysis_path + '/code'
    @base_file_path = @path + '/comcut.c'
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

