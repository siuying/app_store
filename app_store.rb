require 'rubygems'
require 'mechanize'
require 'plist'

class StoreRequestError < StandardError; end

module AppStore
  extend self
  
  def app_url
    @app_url ||= 'http://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware'
  end
  
  def search_url
    @search_url ||= 'http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search'
  end
  
  def store_url
    @store_url ||= 'http://itunes.apple.com/WebObjects/MZStore.woa/wa/countrySelectorPage'
  end
  
  def review_url
    @review_url ||= 'http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews'
  end
  
  # returns an App instance
  def fetch_app_by_id(id, store='143441')
    page  = request(app_url,{:id => id}, store)
    raise StoreRequestError unless page.code == "200"
    plist = Plist::parse_xml(page.body)
    return nil if plist["status-code"]
    app   = App.new(plist["item-metadata"])
  end
  
  # returns an array of first 24 App instances matching "term"
  def search(term, store='143441')
    page = request(search_url, {:media => 'software', :term => term}, store)
    raise StoreRequestError unless page.code == "200"
    plist = Plist::parse_xml(page.body)
    plist["items"].inject([]) { |arr,item| arr << App.new(item) unless item["type"] == "more"; arr }
  end
  
  # return array of Store
  def stores
    unless @stores
      page = request(store_url)
      raise StoreRequestError unless page.code == "200"

      xml = Nokogiri::XML(page.body)
      @stores = xml.css('GotoURL SetFontStyle').collect do |name_node|
        name = name_node.text
        url = name_node.parent.parent['url']
        store_id = url.match(/storeFrontId=([0-9]+)/)[1] rescue nil
        {:name => name, :store_id => store_id }
      end.select {|store| !store[:store_id].nil? }
    end
    @stores
  end

  # return reviews
  def reviews(id, page=0, store='143441')
    page  = request(review_url, {:id => id, :type => "Purple Software", :"displayable-kind" => "11", :"pageNumber" => page}, store)
    raise StoreRequestError unless page.code == "200"
    plist = Plist::parse_xml(page.body) || []
    items = plist["items"] || []
    items.select() { |item| item["type"] != "more" }
  end

  private  
  def request(url, params={}, store='143441')
    @agent ||= WWW::Mechanize.new { |a| a.user_agent = 'iTunes-iPhone/3.0' }
    @agent.get(:url => url, :headers => {"X-Apple-Store-Front" => "#{store}-1,2"}, :params => params)
  end

end

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
  
  def comments
  end
  
end