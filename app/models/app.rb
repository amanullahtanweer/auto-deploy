class App < ApplicationRecord
  belongs_to :server


  def webhook
  	crypt = ActiveSupport::MessageEncryptor.new("\xAC\x8C\x84\x9D\xEA\b\xEC\x92\xBA\xFF\x0E\x9F\xF2\xC3\xC5P[\xAD\xC5A\x82\xCA\x0F\xA0\xE9Oeyg\nL\xF9")
    encrypted_data = crypt.encrypt_and_sign(id)
  end
end
