class LobbyListener
	def initialize(lobby, stream)
		@lobby = lobby
		@stream = SSE::Writer.new(stream)
	end

	def subscribe
		@lobby.subscribe(self)
	end

	def update(json)
		event = json.delete(:event)
		begin
			@stream.write(JSON.parse(json).to_json, :event => event)
    	rescue IOError
    	ensure
      		close
      	end
	end

	def close
		@lobby.unsubscribe(self)
		@stream.close
	end
end