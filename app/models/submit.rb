class Submit < ActiveRecord::Base
  belongs_to :player
  belongs_to :strategy

  validates_presence_of :src_file

  def get_number
    submits = self.player.submits
    submits.present? ? submits.last.number+1 : 1
  end

  def mkdir
    player = self.player
    path = player.league.src_dir.sub("/rule", "") + "/source/%02d" % player.user.id
  end

  def set_src
    player = self.player
    path = player.league.src_dir.sub("/rule", "") + "/source/%02d/%03d" % [player.user.id, self.number]
    begin
      Dir::mkdir(path)
      File.open(path + "/PokerOpe.c", "w") do |f|
        f.puts self.src_file.read.force_encoding("utf-8")
      end
    rescue
      return nil
    end
    path
  end
end

