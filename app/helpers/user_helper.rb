module UserHelper
    def generate_token(params)
        user = User.find_by(user_name: params[:user_name])
        if user && user.authenticate(params[:password])
            payload = {
                user_id: user.id,
                expires_at: 24.hours.from_now
            }
            token = JWT.encode(payload, JWT_SECRET_KEY)
            { success: true, user: user, token: token }
        else
            { success: false, error: "Invalid username or password" }
        end
    end
end