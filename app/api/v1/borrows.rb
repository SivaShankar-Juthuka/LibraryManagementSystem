# app/api/v1/borrows.rb
class Api::V1::Borrows < Grape::API
    resources :members do
        before do
            authenticate!
        end 
        resources :borrows do
            desc "Get all Borrows"
            params do
                optional :page, type: Integer, desc: "Page number"
                optional :per_page, type: Integer, desc: "Number of items per page"
                optional :query, type: String, desc: "Search query"
            end
            get do
                if Current.user.admin? || Current.user.librarian?
                    search_conditions = {
                        member_id_eq: params[:query],
                        book_id_eq: params[:query],
                        issued_copy_eq: params[:query],
                        borrowed_at_cont: params[:query],
                        due_date_cont: params[:query],
                        returned_at_cont: params[:query]
                    }
                    borrow = Borrow.ransack(search_conditions.merge(m: 'or')).result
                    borrow = paginate(borrow)
                    present borrow, with: Api::Entities::Borrow, type: :full
                else
                    error!('You are not authorized to perform this action access', 401)
                end
            end
        end
        
        route_param :member_id do
            resources :borrows do   
                # Get borrow history of a member
                desc "Get borrow history of a member"
                params do
                    optional :page, type: Integer, desc: "Page number"
                    optional :per_page, type: Integer, desc: "Number of items per page"
                    optional :query, type: String, desc: "Search query"
                end
                get do
                    member = Member.find(params[:member_id])
                    if member
                        if Current.user.admin? || (Current.user.librarian? && Current.library_id == member.library_id) || (Current.user.member? && Current.library_id == member.library_id && Current.user.id ==  member.id)
                            search_conditions = {
                                member_id_eq: params[:query],
                                book_id_eq: params[:query],
                                issued_copy_eq: params[:query],
                                borrowed_at_cont: params[:query],
                                due_date_cont: params[:query],
                                returned_at_cont: params[:query]
                            }
                            borrows = member.borrows.ransack(search_conditions.merge(m: 'or')).result
                            borrows = paginate(borrows)
                            present borrows, with: Api::Entities::Borrow, type: :full
                        else
                            error!({error: "You are not authorized to perform this action"}, 403)
                        end
                    else
                        error!({error: "Member not found"}, 404)
                    end                        
                end
        
                route_param :borrow_id do
                    # get a specific borrow history
                    desc "Get a specific borrow history"
                    get do
                        member = Member.find(params[:member_id])
                        borrow = member.borrows.find(params[:borrow_id])
                        present borrow, with: Api::Entities::Borrow, type: :full
                    end

        
                    # edit the borrow history
                    desc "Edit the borrow history"
                    params do
                        requires :returned_at, type: Date, desc: "Return date"
                        optional :is_damaged, type: Boolean, desc: "Damage Status"
                    end
                    put do
                        member = Member.find(params[:member_id])
                        borrow = Borrow.find(params[:borrow_id])
                        if member && borrow
                            if Current.user.librarian? 
                                borrow.update_borrow_history(params.except(:borrow_id, :member_id))
                                present borrow, with: Api::Entities::Borrow
                            else
                                error!('You are not authorized to perform this action', 403)
                            end
                        else
                            error!('Member not found', 404)
                        end
                    end
                end
            end
        end
    end
end