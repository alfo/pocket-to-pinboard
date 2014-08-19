require "pocket"
require 'open-uri'
require 'pp'
require_relative "bookmark"

class PocketFeed
  def initialize(consumer_key, access_token)

    Pocket.configure do |c|
      c.consumer_key = consumer_key
    end

    @access_token = access_token
  end

  def feed

    @feed ||= begin
      client = Pocket.client(:access_token => @access_token)
    end
  end

  def bookmarks(since: nil)

    items = feed.retrieve(state: 'archive', sort: 'newest', detailType: 'complete', since: since.to_i)

    the_bookmarks = items['list']

    return_items = []

    the_bookmarks.each do |item|

      item = item[1]

      bookmark_tags = []

      if item['tags']
        item['tags'].each do |tag|
          bookmark_tags << tag[0].gsub(' ', '_')
        end
      end

      if item['resolved_url']
        if item['resolved_url'].empty?
          url = item['given_url']
        else
          url = item['resolved_url']
        end
      else
        url = item['given_url']
      end

      if item['resolved_title']
        if item['resolved_title'].empty?
          title = item['given_title']
        else
          title = item['resolved_title']
        end
      else
        title = item['given_title']
      end

      bookmark = Bookmark.new(url, title, item['excerpt'], bookmark_tags)

      return_items << bookmark
    end

    return_items
  end

end
