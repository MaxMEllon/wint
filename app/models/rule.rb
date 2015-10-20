class Rule < ActiveModelBase
  attr_accessor :path, :change, :take, :try

  public_constant

  TIME_LIMIT = 30

  private_constant

  module FileName
    CARD = 'CardLib.c'
    EXEC = 'PokerExec.c'
    HEADER = 'Poker.h'
    STOCK = 'Stock.ini'
    JSON = 'rule.json'
  end

  DIR_NAME = 'rule'

  public

  def initialize(attributes = {})
    @path = attributes[:path] + '/' + DIR_NAME
    @change = attributes[:change]
    @take = attributes[:take]
    @try = attributes[:try]
    @card_data = attributes[:card]
    @exec_data = attributes[:exec]
    @header_data = attributes[:header]
    @stock_data = attributes[:stock]
  end

  # @Override
  def save
    FileUtils.mkdir(@path) unless File.exist?(@path)
    reg = { change: @change, take: @take, try: @try }
    json_data = ModelHelper.encode_json reg
    write_file FileName::JSON, json_data
    write_file FileName::CARD, @card_data
    write_file FileName::EXEC, @exec_data
    write_file FileName::HEADER, @header_data
    write_file FileName::STOCK, @stock_data
    true
  rescue
    false
  end

  # @Override
  def update(attributes = {})
    @card_data = attributes[:card]
    @exec_data = attributes[:exec]
    @header_data = attributes[:header]
    @stock_data = attributes[:stock]
    @change = attributes[:change]
    @take = attributes[:take]
    @try = attributes[:try]
    save
  end

  def compile_command(src_file, exec_file)
    files = "#{src_file} #{path}/#{FileName::EXEC} #{path}/#{FileName::CARD}"
    opt = format('-DTYPE=%02d-%02d -DTAKE=%d -DCHNG=%d', take, change, take, change)
    "gcc -O2 -w -I #{path} #{files} #{opt} -o #{exec_file}"
  end

  def execute_command(exec_file)
    docker_tmp = '/var/tmp'
    volume_stock = "-v #{path}/#{FileName::STOCK}:#{docker_tmp}/tmp.ini"
    volume_exec = "-v #{exec_file}:#{docker_tmp}/tmp.exe"
    opt = 'ubuntu:14.04 /bin/bash -c'
    exec_cmd = [
      "mkdir #{docker_tmp}/log",
      "cd #{docker_tmp}",
      "timeout #{TIME_LIMIT} #{docker_tmp}/tmp.exe _tmp #{try} #{docker_tmp}/tmp.ini 1"
    ].join(' && ')
    cmd = [volume_stock, volume_exec, opt, "'#{exec_cmd}'"].join(' ')
    cmd = "--rm #{cmd}" unless ENV['CIRCLECI']
    "docker run #{cmd}"
  end

  def text
    [format('%02d', @change), format('%02d', @take), @try].join('-')
  end

  def regulation
    reg = ModelHelper.decode_json File.read("#{@path}/#{FileName::JSON}")
    reg.map { |k, v| [k, v.to_i] }.to_h
  rescue
    { change: 0, take: 0, try: 0 }
  end

  private

  def write_file(filename, data)
    return if data.nil?
    File.write "#{@path}/#{filename}", data
  end

  public_class_method

  # @Override
  def self.create(attributes = {})
    Rule.new(attributes).tap(&:save)
  end

  # @Override
  def self.load(path)
    Rule.new(path: path).tap do |rule|
      reg = rule.regulation
      rule.change = reg[:change]
      rule.take = reg[:take]
      rule.try = reg[:try]
    end
  end
end

