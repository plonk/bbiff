require 'fileutils'
require 'toml'

module Bbiff

class Settings
  attr_accessor :current

  APP_NAME = 'bbiff'

  def initialize
    @current = default.dup
    @config_dir = "#{ ENV['HOME'] }/.config/#{ APP_NAME }"
    load
  end

  def default
    { 'delay_seconds' => 10, 'bbiff_show' => 'bbiff-show' }
  end

  def load
    if File.readable?("#{@config_dir}/settings.tml")
      prefs = TOML.load_file("#{@config_dir}/settings.tml")
      self.current = current.merge(prefs)
    end
  end

  def save
    FileUtils.mkdir_p(@config_dir)
    prefs = (current.to_a - default.to_a).to_h
    File.open("#{@config_dir}/settings.tml", 'w') do |f|
      f.write(TOML.dump(prefs))
    end
  end

end

end

# settings = Bbiff::Settings.new

# p settings.default
# p settings.current

# settings.current['delay_seconds'] = 7
# settings.current['thread_url'] = 'http://jbbs.shitaraba.net/bbs/read.cgi/game/48538/1454983964'
# settings.save
