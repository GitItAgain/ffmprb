module Ffmprb

  VERSION = '0.11.3'

  GEM_GITHUB_URL = 'https://github.com/showbox-oss/ffmprb'

  FIREBASE_AVAILABLE =
    begin
      require 'firebase'
      true
    rescue Exception
    end

end
