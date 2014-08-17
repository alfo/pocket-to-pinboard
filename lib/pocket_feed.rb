require "httparty"
require "rss"
require_relative "bookmark"

class PocketFeed
  def initialize(username, password)
    @username = username
    @password = password
  end

  def feed
    @feed ||= begin
      response = HTTParty.get("http://getpocket.com/users/noniq/feed/read", basic_auth: { username: @username, password: @password })
      raise "Error loading RSS feed: #{response.body}" unless response.code == 200
      RSS::Parser.parse(response)
    end
  end

  def bookmarks(since: nil)
    items = feed.items.dup
    items.reject!{ |item| item.pubDate < since } if since

    return_items = []

    items.each do |item|
      tags = item.tags.map { |tag| tag.sub!(' ', '_')}
      bookmark = Bookmark.new(item.link, item.title, tags)
      return_items << bookmark
    end

    return_items
  end

end
