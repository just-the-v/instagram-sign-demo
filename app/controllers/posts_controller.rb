# frozen_string_literal: true

require 'open-uri'

class PostsController < ApplicationController
  def index
    return render 'posts/sign' unless current_user

    @posts = current_user.posts.order(:created_at).with_attached_image
  end

  def destroy
    current_user.posts.each do |post|
      post.image.purge
      post.destroy!
    end

    redirect_to root_path
  end

  def fetch_instagram
    return redirect_back fallback_location: root_path unless current_user.instagram_token

    client = InstagramBasicDisplay::Client.new(auth_token: current_user.instagram_token)
    media_feed = client.media_feed(fields: %i[id caption media_url media_type]).body['data']
    media_feed.each do |media|
      next if media['media_type'] == 'VIDEO'

      url = media['media_url']
      Post.find_or_create_by!(unique_id: media['id']) do |post|
        post.user = current_user
        post.caption = media['caption']
        post.source = 'instagram'
        post.image.attach(io: URI.parse(url).open, filename: File.basename(url))
      end
    end

    redirect_to root_path
  end
end
