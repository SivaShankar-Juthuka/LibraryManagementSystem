# app/api/v1/requests.rb
class Api::V1::Requests < Grape::API
    resources :members do
        before do
            authenticate!
        end
        
        resources :requests do
            # get all requests
            desc "Get all requests"
            params do
                optional :page, type: Integer, desc: "Page number"
                optional :per_page, type: Integer, desc: "Number of items per page"
                optional :query, type: String, desc: "Search query"
            end
            get do
                if Current.user.admin? || Current.user.librarian?
                    search_conditions ={
                        id_eq: params[:query],
                        member_id_eq: params[:query],
                        book_id_eq: params[:query],
                        requested_at_cont: params[:query],
                        is_approved_matches: params[:query]
                    }
                    requests = Request.ransack(search_conditions.merge(m: 'or')).result
                    requests = paginate(requests)
                    present requests, with: Api::Entities::Request, type: :full
                else
                    error!('You are not authorized to perform this action', 401)
                end
            end
        end

        route_param :member_id do
            resources :requests do
                # get all request of member
                desc "Get all requests of member"
                params do
                    optional :page, type: Integer, desc: "Page number"
                    optional :per_page, type: Integer, desc: "Number of items per page"
                    optional :query, type: String, desc: "Search query"
                end
                get do
                    member = Member.find(params[:member_id])
                    if member
                        if Current.user.admin? || (Current.user.librarian? && Current.library_id ==  member.library_id) || (Current.user.member? && Current.user.id == member.user_id)
                            search_conditions = {
                                id_eq: params[:query],
                                member_id_eq: params[:query],
                                book_id_eq: params[:query],
                                requested_at_matches_any: params[:query],
                                is_approved_matches: params[:query]
                            }
                            requests = member.requests.ransack(search_conditions.merge(m: 'or')).result
                            requests = paginate(requests)
                            present requests, with: Api::Entities::Request, type: :full
                        else
                            error!({message: "You are not authorized to perform this action"}, 401)
                        end
                    else
                        error!('Member not found', 404)
                    end
                end

                # get specifc request
                desc "Get specific request of member"
                params do
                    requires :id, type: Integer, desc: "Request ID"
                end
                get ':id' do
                    member = Member.find(params[:member_id])
                    if (Current.user.librarian? && Current.library_id ==  member.library_id) || (Current.user.member? && Current.user.id == member.user_id)
                        request = Request.find(params[:id])
                        present request #, with: Entities::Request
                    else
                        error!({message: "You are not authorized to perform this action"}, 401)
                    end
                end

                # create a requst for a book
                desc "Create a request for a book"
                params do
                  requires :book_id, type: Integer, desc: "Book ID"
                  requires :library_id, type: Integer, desc: "Library ID"
                end
                post do
                    member = Member.find(params[:member_id])
                    if member
                        if Current.user.member? && Current.user.id == member.user_id && Current.library_id == member.library_id && member.library_id == params[:library_id]
                        result = Request.create_request(params[:member_id], params[:book_id], params[:library_id])
                        if result[:success]
                            present result[:request]
                        else
                            error!(result[:error], 422)
                        end
                        else
                            error!({ message: "You are not authorized to perform this action" }, 401)
                        end
                    else
                        error!('Member not found', 404)
                    end
                end
                

                # edit the request
                desc "Edit the request"
                params do
                    requires :id, type: Integer, desc: "Request ID"
                    optional :is_approved, type: Boolean, desc: "Approved status"
                end
                put ':id' do
                    member = Member.find(params[:member_id])
                    if member
                        if Current.user.librarian? && Current.library_id == member.library_id
                            result = Request.edit_request(params[:id], params[:member_id], params, Current.user)
                            if result[:success]
                                present result[:request], with: Api::Entities::Request
                            else
                                error!(result[:error], 422)
                            end
                        else
                            error!('You are not authorized to perform this action', 401)
                        end
                    else
                        error!('Member not found', 404)
                    end
                end
            end
        end
    end
end