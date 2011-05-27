module AppStore
  class App
    attr_reader :item_id, :title, :url, :icon_url, :price, :release_date

    def initialize(hash)
      @item_id      = hash["item-id"]
      @title        = hash["title"]
      @url          = hash["url"]
      @icon_url     = hash["artwork-urls"][0]["url"]
      @price        = hash["store-offers"]["STDQ"]["price"]
      @release_date = hash["release-date"]
    end

    def reviews(page=0, store='143441')
      AppStore.reviews(@item_id, page, store)
    end

  end
end