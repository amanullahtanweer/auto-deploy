class ServerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "server:#{params[:id]}"
  end

  def unsubscribed
  	stop_all_streams
  end
end
