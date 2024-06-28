# app/api/v1/fines.rb
class Api::V1::Fines < Grape::API
    resources :libraries do
        before do
            authenticate!
        end
        resources :members do
            resources :fines do
                desc "Get all fines"
                params do
                    optional :page, type: Integer, desc: "Page number"
                    optional :per_page, type: Integer, desc: "Number of items per page"
                    optional :query, type: String, desc: "Search query"
                end
                get do
                    if Current.user.admin? || Current.user.librarian?
                        search_conditions = {
                            id_eq: params[:query], 
                            fine_amount_eq: params[:query],
                            paid_status_matches: params[:query],
                            paid_at: params[:query],
                            fine_type: params[:query]
                        }
                        fine_histories = Fine.ransack(search_conditions.merge(m: 'or')).result
                        fine_histories = paginate(fine_histories)
                        present fine_histories, with: Api::Entities::Fine, type: :full
                    else
                        error!('Not authorized', 401)
                    end
                end
            end
        end

        route_param :library_id do
            resources :members do
                route_param :member_id do
                    resource :fines do
                        desc "Get all fines for a member"
                        params do
                            optional :page, type: Integer, desc: "Page number"
                            optional :per_page, type: Integer, desc: "Number of items per page"
                            optional :query, type: String, desc: "Search query"
                        end
                        get do
                            member = Member.find(params[:member_id])
                            if Current.user.admin? || Current.user.librarian? || Current.user.id == member.user.id
                                search_conditions = {
                                book_id_eq: params[:query],
                                issued_copy_eq: params[:query],
                                borrowed_at_cont: params[:query],
                                due_date_cont: params[:query],
                                returned_at_cont: params[:query]
                                }
                                fines = member.fines.ransack(search_conditions.merge(m: 'or')).result
                                fines = paginate(fines)
                                present fines, with: Api::Entities::Fine, type: :full
                            else
                                error!('Not authorized', 401)
                            end
                        end
            
                        # Edit fine for a member
                        desc "Edit fine for a member"
                        params do
                            requires :id, type: Integer, desc: "ID of the fine"
                            requires :paid_status, type: Boolean, desc: "Paid status of the fine"
                        end
                        put ':id' do
                            member = Member.find(params[:member_id])
                            if Current.user.librarian? && Current.library_id  == member.library_id 
                                fine = Fine.find(params[:id])
                                fine.update(paid_status: params[:paid_status])
                                present fine, with: Api::Entities::Fine, type: :full
                            else
                                error!('Unauthorized', 401)
                            end
                        end
            
                        # Delete fine for a member
                        desc "Delete fine for a member"
                        delete ':id' do
                            if Current.user.libararian?
                                fine = Member.find(params[:member_id]).fines.find(params[:id])
                                fine.destroy
                                present message: "Fine deleted successfully"
                            else
                                error!('Unauthorized', 401)
                            end
                        end
                    end
                end
            end
        end
    end
end
