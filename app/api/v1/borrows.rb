# app/api/v1/borrows.rb
class Api::V1::Borrows < Grape::API
    resources :member do
        before do
            authenticate!
        end 
        resources :borrow do
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
                    error!('Unauthorized access', 401)
                end
            end
        end
        
        route_param :member_id do
            resources :borrow do   
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
                        if (Current.user.librarian? && Current.library_id ==  member.library_id) || (Current.user.member? && Current.user.id == member.user_id)
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
                            error!({message: "You are not allowed to access this resource"}, 403)
                        end
                    else
                        error!({message: "Member not found"}, 404)
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
                        requires :book_id, type: Integer, desc: "Book ID"
                        requires :returned_at, type: Date, desc: "Return date"
                        optional :is_damaged, type: Boolean, desc: "Damage Status"
                    end
                    put do
                        member = Member.find(params[:member_id])
                        if member
                            if Current.user.librarian? && Current.library_id  ==  member.library_id
                                borrow = member.borrows.find(params[:borrow_id])
                                if borrow
                                    updated_borrow = borrow.update_borrow_history(declared(params).except(:borrow_id, :member_id))
                                    present updated_borrow, with: Api::Entities::Borrow, type: :full
                                else
                                    error!('Borrow not found', 404)
                                end
                            else
                                error!('You are not allowed to access this resource', 403)
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