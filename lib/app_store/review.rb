module AppStore
  class Review
    attr_reader :rating, :text, :title, :username, :date, :position, :on_version

    def initialize(hash)
      @rating         = hash["average-user-rating"]
      @text           = hash["text"]
      @title          = hash["title"]
      
      match = hash["title"].match(/^([0-9]+)\. (.*) \(v(.*)\)$/) rescue nil
      if match
        @position       = match[1]
        @title          = match[2]
        @on_version     = match[3]
      end
      
      match = hash["user-name"].match(/^(.+) on (.+)$/) rescue nil
      if match
        @username       = match[1]
        @date           = match[2]
      end
    end
  end
end