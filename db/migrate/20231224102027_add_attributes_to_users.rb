# frozen_string_literal: true

class AddAttributesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :instagram_username, :string
    add_column :users, :instagram_id, :string
    add_column :users, :instagram_token, :string
    add_column :users, :instagram_token_expires_at, :datetime
  end
end
