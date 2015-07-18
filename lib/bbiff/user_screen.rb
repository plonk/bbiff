require 'etc'

class UserScreen
  def initialize(user)
    case user
    when String
      @uid = Etc.getpwnam(user).uid
    when Fixnum
      @uid = user
    else
      fail ArgumentError
    end
  end

  def write(str)
    File.open(user_pty, "w") do |pty|
      pty.print str
    end
  end

  private

  # Returns the file name of most recently used Pseudo Terminal opened
  # by the user
  def user_pty
    Dir.glob('/dev/pts/*')
      .map { |fn| [fn, File.stat(fn)] }
      .select { |name, stat| stat.uid == @uid }
      .sort_by { |_,stat| stat.atime }
      .reverse
      .first.first
  end
end
