# app/api/v1/fines.rb
class Api::V1::Fines < Grape::API
    resources :member do
        before do
            authenticate!
        end
        resources :fine do
            # Get all fine histories
            get do
                if Current.user.admin? || Current.user.librarian?
                    fine_histories = Fine.all
                    present fine_histories#, with: Api::V1::Entities::FineHistory
                else
                    error!('Not authorized', 401)
                end
            end
        end

        route_param :member_id do
            resource :fine do
                # Get all fines for a member
                desc "Get all fines for a member"
                get do 
                    fines = Member.find(params[:member_id]).fines
                    present fines
                end
    
                # Edit fine for a member
                desc "Edit fine for a member"
                params do
                    requires :id, type: Integer, desc: "ID of the fine"
                    requires :paid_status, type: Boolean, desc: "Paid status of the fine"
                end
                put ':id' do
                    if Current.user.admin? ||  Current.user.librarian?
                        fine = Member.find(params[:member_id]).fines.find(params[:id])
                        if fine.update(params)
                            present fine
                        else
                            error!(fine.errors.full_messages, 422)
                        end
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
