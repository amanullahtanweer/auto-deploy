class AppChannel < ApplicationCable::Channel
  def subscribed
    stream_from "app:#{params[:id]}"
  end

  def unsubscribed
  	stop_all_streams
  end
end
