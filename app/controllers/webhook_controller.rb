class WebhookController < ActionController::Base

	def index
    crypt = ActiveSupport::MessageEncryptor.new("\xAC\x8C\x84\x9D\xEA\b\xEC\x92\xBA\xFF\x0E\x9F\xF2\xC3\xC5P[\xAD\xC5A\x82\xCA\x0F\xA0\xE9Oeyg\nL\xF9")
    encrypted_data = params[:hook_id]
    decrypted_back = crypt.decrypt_and_verify(encrypted_data)
    @app = App.find(decrypted_back)
    if @app
      AppDeployJob.perform_later(@app)

      render json: {success: "Webhook success!"}, :status => 200
    else
      render json: {success: "No such webhook exsits"}, :status => 400
    end

  end

end