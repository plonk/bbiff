module Bbiff

  class Settings
    attr_accessor :current

    def initialize
      @current = {
        'delay_seconds' => 7,
        'bbiff_show' => 'bbiff-show',
        'no_render' => false,
        'long_polling' => false,
      }
    end
  end

end
