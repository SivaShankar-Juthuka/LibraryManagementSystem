# app/api/v1/users.rb
class Api::V1::Users < Grape::API
    resources  :users do
        desc "Create a new user"
        params do
            requires :email, type: String, desc: "Email address"
            requires :password, type: String, desc: "Password"
            requires :user_name, type: String, desc: "User name"
        end
        post :signup do
            # check if already logged in or not
            token = request.headers['authorization']&.split(' ')&.last
            if token && !BlackListToken.exists?({token: token})
                error!("Already logged in", 401)
            else
                # create user
                user = User.create!(params)
                if user
                    present user, with: Api::Entities::User, type: :full
                else
                    error!("User not created", 400)
                end
            end
        end            
            
        desc 'User Login'
        params do
            requires :user_name, type: String, desc: 'Email address'
            requires :password, type: String, desc: 'Password'
        end
        post :login do
            user = User.find_by(user_name: params[:user_name])
            if user && user.authenticate(params[:password])
                token = request.headers['authorization']&.split(' ')&.last
                if !BlackListToken.exists?(token: token) && token
                    payload = JWT.decode(token, JWT_SECRET_KEY).first
                    token_user_id = payload['user_id']
                    expires_at = payload['expires_at']
                    if token_user_id == user.id
                        if expires_at > Time.now
                            present({ token: token, user: user }, with: Api::Entities::Login)
                        else
                            result = generate_token(params)
                            if result[:success]
                                present({ token: result[:token], user: result[:user] }, with: Api::Entities::Login)
                            else
                                error!({ error: result[:error] }, 422)
                            end
                        end
                    else
                        error!('You are already logged in with a different user. Please log out to log in with a different account.', 403)
                    end
                else
                    result = generate_token(params)
                    if result[:success]
                        present({ token: result[:token], user: result[:user] }, with: Api::Entities::Login)
                    else
                        error!({ error: result[:error] }, 422)
                    end                    
                end
            else
                error!('Invalid email or password', 422)
            end
        end

        before do
            authenticate!
        end

        # Get all librarians details
        desc "All Librarian details"
        params do
            optional :query, type: String, desc: 'Search query string'
            optional :page, type: Integer, default: 1, desc: 'Page number'
            optional :items, type: Integer, default: 5, desc: 'Number of Items for page.'
        end
        get 'librarians' do
            if Current.user.admin?
                search_conditions = {
                    id_eq: params[:query],
                    library_id_cont: params[:query]
                  }
                librarians = Librarian.ransack(search_conditions.merge(m: 'or')).result
                librarians = paginate(librarians)
                present librarians, with: Api::Entities::Librarian, type: :full
            else
                error!("Only admin can view all librarians", 401)
            end
        end

        # Get all the members details
        desc 'All Member details'
        params do
            optional :query, type: String, desc: 'Search query string'
            optional :page, type: Integer, default: 1, desc: 'Page number'
            optional :items, type: Integer, default: 5, desc: 'Number of Items for page.'
        end
        get 'members' do
            if Current.user.admin?
                search_conditions ={
                    id_eq: params[:query],
                    member_id_eq: params[:query],
                    library_id_eq: params[:query],
                    borrowing_limit: params[:query]
                }
                members = Member.ransack(search_conditions.merge(m: 'or')).result
                members = paginate(members)
                present members, with: Api::Entities::Member, type: :full
            else
                error!("Only admin can view all members", 401)
            end
        end

        # List of all users
        desc "List of all users"
        params do
            optional :query, type: String, desc: 'Search query string'
            optional :page, type: Integer, default: 1, desc: 'Page number'
            optional :items, type: Integer, default: 5, desc: 'Number of Items for page.'
        end
        get do
            if Current.user.admin?
                search_conditions = {
                    id_eq: params[:query],
                    email_eq: params[:query],
                    user_name_cont: params[:query],
                    is_assigned_matches: params[:query]
                }
                users = User.ransack(search_conditions.merge(m: 'or')).result
                users = paginate(users)
                present users, with: Api::Entities::User, type: :private
            else
                error!("Unauthorized access", 401)
            end
        end

        # User Logout
        desc "Logout user"
        delete :logout do
            token = request.headers['Authorization']&.split(' ')&.last
            if token
                begin
                    BlackListToken.create!(token: token)
                    present message: 'Logged out successfully'
                rescue => e
                    error!("Failed to blacklist token: #{e.message}", 500)
                end
            else
                error!('Unauthorized - No token provided', 401)
            end
        end


        route_param :user_id do

            # Updates details of a specific user by ID.
            desc "Update user details"
            params do
                optional :user_name, type: String, desc: "User name"
                optional :email, type: String, desc: "User email"
            end
            put do
                if Current.user.admin?
                    user = User.find_by(id: params[:user_id])
                    user.update!(params.except(:user_id))
                    present user, with: Api::Entities::User
                else
                    error!("Unauthorized access", 401)
                end
            end

            # delete details of specific user
            desc "Delete user details"
            delete do
                if Current.user.admin?
                    user = User.find(params[:user_id])
                    if user
                        user.destroy
                        present user, with: Api::Entities::User, type: :full
                        # present the messsage
                        present message: "User deleted successfully"
                    else
                        error!("User not found", 404)
                    end
                else
                    error!("Unauthorized access", 401)
                end
            end

            resources :libraries do
                route_param :library_id do
                    # Assign user as librarian to a library 
                    desc "Assign user as librarian to a library"
                    post '/assign_librarian' do
                        if Current.user.admin?
                            librarian = User.assign_librarian(params[:user_id], params[:library_id])
                            present librarian, with: Api::Entities::Librarian
                        else
                            error!("Only admin can assign librarian", 401)
                        end
                    end

                    # Assigning user as member to a library
                    desc "Assign user as member"
                    post '/assign_member' do
                        if Current.user.admin?
                            member = User.assign_member(params[:user_id], params[:library_id])
                            present member, with: Api::Entities::Member
                        else
                            error!("Unauthorized access", 401)
                        end
                    end

                    # Change Librarian's assigned library.
                    desc "Change librarian's assigned library"
                    put '/change_librarian_library' do
                        if Current.user.admin?
                            librarian = Librarian.change_library(params[:user_id], params[:library_id])
                            present librarian, with: Api::Entities::Librarian
                        else
                            error!('Unauthorized access', 401)
                        end
                    end
                end
            end
        end
    end
end