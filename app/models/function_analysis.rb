class FunctionAnalysis
  attr_reader :func_ref_path

  def initialize(cflow)
    @cflow = cflow
    @func_ref_path = create_func_ref
  end

  def create_func_ref
    reference = get_reference
    @cflow.path.sub(/cflow.dat/, "func_ref.csv").tap do |path|
      File.open(path, "w") { |f| f.puts reference_to_matrix(reference) }
    end
  end

  def get_reference
    reference = {}
    key = ""
    @cflow.data.split(/\r\n|\n/).each do |line|
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

