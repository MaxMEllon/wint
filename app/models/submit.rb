class Submit < ActiveRecord::Base
  belongs_to :player
  belongs_to :strategy

  validates_presence_of :data_dir

  def src_file
    self.data_dir + "/PokerOpe.c"
  end

  def exec_file
    self.data_dir + "/PokerOpe"
  end

  def get_number
    submits = self.player.submits
    submits.present? ? submits.last.number+1 : 1
  end

  def mkdir
    (self.player.data_dir + "/%03d" % self.number).tap do |path|
      Dir::mkdir(path)
    end
  end

  def set_data(source)
    File.open(self.src_file, "w") {|f| f.puts source}
  end
end

