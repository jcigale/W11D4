# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
    validates :username, :password_digest, :session_token, presence: true
    validates :username, :session_token, uniqueness: true
    validates :password, length: {minimum: 6}, allow_nil: true
    attr_reader :password
    after_initialize :ensure_session_token!

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
    end

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)
        if user && user.check_password?(password)
            return user
        end
        nil
    end

    def check_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

    def generate_session_token
        self.session_token = SecureRandom.urlsafe_base64(16)
        # while User.find_by(session_token: self.session_token)
        #     self.session_token = SecureRandom.urlsafe_base64(16)
        # end
        # self.session_token
    end

    def reset_session_token
        generate_session_token
        save!
        self.session_token
    end

    def ensure_session_token!
        if !self.session_token
            generate_session_token
        end
    end

end
