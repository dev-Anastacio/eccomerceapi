# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def self.up
    change_table :users do |t|
      ## Database authenticatable
      # Renomeia password_digest → encrypted_password
      t.rename :password_digest, :encrypted_password

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable (opcional - descomente se quiser)
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable (opcional)
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email

      ## Lockable (opcional)
      # t.integer  :failed_attempts, default: 0, null: false
      # t.string   :unlock_token
      # t.datetime :locked_at
    end

    # Adiciona índices (email já tem índice, mas reforça como único)
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end

  def self.down
    change_table :users do |t|
      t.rename :encrypted_password, :password_digest
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      t.remove :remember_created_at
    end

    remove_index :users, :reset_password_token if index_exists?(:users, :reset_password_token)
  end
end