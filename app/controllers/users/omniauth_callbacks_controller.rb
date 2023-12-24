# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :instagram

    def instagram
      return head :bad_request unless params[:code]

      extract_token_expired_at
      user = find_or_create_user
      sign_in user
      redirect_to root_path
    end

    private

    def extract_token_expired_at
      client = InstagramBasicDisplay::Client.new
      long_token_request = client.long_lived_token(access_code: params[:code])
      @expired_at = long_token_request.payload['expires_in'].seconds.from_now
      @token = long_token_request.payload['access_token']
    end

    def find_or_create_user
      profile = InstagramBasicDisplay::Client.new(auth_token: @token).profile
      user_instagram_id = profile.payload['id']
      User.find_or_create_by!(instagram_id: user_instagram_id) do |user|
        user.instagram_username = profile.payload['username']
        user.email = "#{user_instagram_id}@instagram.fake"
        user.password = Devise.friendly_token
        user.provider = 'instagram'
        user.instagram_token = @token
        user.instagram_token_expires_at = @expired_at
      end
    end
  end
end
