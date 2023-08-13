module ApplicationCable        
  class Connection < ActionCable::Connection::Base 
    identified_by :current_user
 
    def connect
      self.current_user = find_verified_user
    end
 
    private
      def find_verified_user   
        begin
          id_token = request.params['id_token']
          decoded = Auth.decode_token(id_token)
          User.find_hash_by(id: decoded['id'])
        rescue
          nil
        end
      end
  end
end