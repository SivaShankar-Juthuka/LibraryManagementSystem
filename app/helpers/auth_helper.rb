# app/helpers/auth_helper.rb
module AuthHelper
  def authenticate!
    token = request.headers['Authorization']&.split(' ')&.last
    puts "Extracted Token: #{token}"
    
    if token
      begin
        payload = JWT.decode(token, JWT_SECRET_KEY, true, algorithm: 'HS256').first
        expires_at = payload['expires_at']
        user_id = payload['user_id']
        puts "User ID from token: #{user_id}"
        if expires_at < Time.now
          BlackListToken.create!(token: token)
          error!('Token Expired &&&', 401)
        elsif BlackListToken.exists?(token: token)
          error!('User already logged out', 401)
        else
          user = User.find_by(id: user_id)
          if user.nil?
            error!('Unauthorized - Invalid token', 401)
          else
            Current.user = user
            set_current_library_id(user)
          end
        end
      rescue JWT::DecodeError => e
        error!("Unauthorized - Invalid token: #{e.message}", 401)
      end
    else
      error!('Unauthorized - No token provided', 401)
    end
  end

  private

  def set_current_library_id(user)
    if user.librarian?
      librarian = Librarian.find_by(user_id: user.id)
      Current.library_id = librarian&.library_id
    elsif user.member?
      member = Member.find_by(user_id: user.id)
      Current.library_id = member&.library_id
    end
    puts "Current Library ID: #{Current.library_id}"
  end
end
