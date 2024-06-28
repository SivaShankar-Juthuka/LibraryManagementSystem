# app/api/v1/libraries.rb
class Api::V1::Libraries < Grape::API
    resources :libraries do
        before do
            authenticate!
        end

        # Get all libraries
        desc "Get all libraries"
        params do
            optional :page, type: Integer, desc: "Page number"
            optional :per_page, type: Integer, desc: "Number of items per page"
            optional :query, type: String, desc: "Search query"
        end
        get do
            if Current.user.admin?
                search_conditions ={
                    id_eq: params[:query],
                    library_name_cont: params[:query],
                    library_address_cont: params[:query]
                }
                libraries = Library.ransack(search_conditions.merge(m: 'or')).result
                library = paginate(libraries)
                present library, with: Api::Entities::Library, type: :full
            else
                error!('You are not authorized to perform this action', 401)
            end
        end
        
        # Creating libraries
        desc "Create a Library"
        params do
            requires :library_name, type: String, desc: "Library name"
            requires :library_address, type: String, desc: "Library address"
        end
        post do
            if Current.user.admin?
                library = Library.new(
                    library_name: params[:library_name],
                    library_address: params[:library_address]
                )
                if library.save
                    present message: "Library created successfully", library: library, with: Api::Entities::Library, type: :full
                else
                    error!({ error: "Failed to create library" }, 400)
                end
            else
                error!({ error: "You are not authorized to perform this action" }, 401)
            end
        end
        
        resources :fine_rates do
            desc "Get all fine rates"
            params do
                optional :page, type: Integer, desc: "Page number"
                optional :per_page, type: Integer, desc: "Number of items per page"
                optional :query, type: String, desc: "Search query"
            end
            get do
                if Current.user.admin?
                    search_conditions ={
                        id_eq: params[:query],
                        fine_amount_cont: params[:query],
                        fine_type_cont: params[:query],
                        library_id_eq: params[:query]
                    }
                    fine_rates = FineRate.ransack(search_conditions.merge(m: 'or')).result
                    fine_rate = paginate(fine_rates)
                    present fine_rate, with: Api::Entities::FineRate, type: :full
                else
                    error!({ error: "You are not authorized to perform this action" }, 401)
                end
            end
        end

        resources :book_inventories do
            desc "Get all book inventories"
            params do
                optional :page, type: Integer, desc: "Page number"
                optional :per_page, type: Integer, desc: "Number of items per page"
                optional :query, type: String, desc: "Search query"
            end
            get do
                if Current.user.admin?
                    search_conditions ={
                        id_eq: params[:query],
                        book_id_eq: params[:query],
                        library_id_eq: params[:query],
                        copies_borrowed_eq: params[:query],
                        copies_available_eq: params[:query],
                        copies_reserved_eq: params[:query]
                    }
                    book_inventories = BookInventory.ransack(search_conditions.merge(m:'or')).result
                    book_inventories = paginate(book_inventories)
                    present book_inventories, with: Api::Entities::BookInventory, type: :full
                else
                    error!({ error: "You are not authorized to perform this action" }, 401)
                end
            end
        end

        route_param :library_id do
            # Get the Specific library details
            desc "Get a Library"
            params do
                optional :page, type: Integer, desc: "Page number"
                optional :per_page, type: Integer, desc: "Number of items per page"
                optional :query, type: String, desc: "Search query"
            end
            get do
                if Current.user.admin? || Current.library_id == params[:library_id]
                    search_conditions ={
                        id_eq: params[:query],
                        library_name_cont: params[:query],
                        library_address_cont: params[:query]
                    }
                    libraries = Library.where(id: params[:library_id])
                    libraries = libraries.ransack(search_conditions.merge(m: 'or')).result
                    libraries = paginate(libraries)
                    present libraries, with: Api::Entities::Library, type: :full
                else
                    error!({ error: "You are not authorized to perform this action" }, 401)
                end
            end

            # update the details of library
            desc "Update a Library"
            params do
                optional :library_name, type: String, desc: "Library name"
                optional :library_address, type: String, desc: "Library address"
            end
            put do
                if Current.user.admin? || (Current.user.librarian? && Current.library_id ==  params[:library_id])
                    library = Library.find_by(id: params[:library_id])
                    if library
                        library.update(params.except(:library_id))
                        present library, with: Api::Entities::Library, type: :full
                    else
                        error!({ error: "Library not found" }, 404)
                    end
                else
                    error!({ error: "You are not authorized to perform this action" }, 401)
                end
            end

            # delete a library
            desc "Delete a Library"
            delete do
                if Current.user.admin?
                    library = Library.find(params[:library_id])
                    if library
                        library.destroy
                        present message: "Library deleted successfully"
                    else
                        error!({ error: "Library not found" }, 404)
                    end
                else
                    error!({ error: "You are not authorized to perform this action" }, 401)
                end
            end

            # Librarians for particular library id
            desc "Get all librarians for a specific library"
            params do
                optional :page, type: Integer, desc: "Page number"
                optional :per_page, type: Integer, desc: "Number of items per page"
                optional :query, type: String, desc: "Search query"
            end
            get 'librarians' do
                if Current.user.admin? || (Current.user.librarian? && Current.library_id ==  params[:library_id])
                    library = Library.find(params[:library_id])
                    search_conditions ={
                            id_eq: params[:query],
                            library_name_cont: params[:query],
                            library_address_cont: params[:query]
                        }
                    if library
                        librarians = library.librarians.ransack(search_conditions.merge(m: 'or')).result
                        librarians = paginate(librarians)
                        present librarians, with: Api::Entities::Librarian, type: :full
                    else
                        error!('Library not found', 404)
                    end
                else
                    error!({ error: "You are not authorized to perform this action" }, 401)
                end
            end

            desc "Get all members for a specific library"
            params do
                optional :page, type: Integer, desc: "Page number"
                optional :per_page, type: Integer, desc: "Number of items per page"
                optional :query, type: String, desc: "Search query"
            end
            get 'members' do
                if Current.user.admin? || (Current.user.librarian? && Current.library_id ==  params[:library_id])
                    library = Library.find(params[:library_id])
                    search_conditions ={
                        id_eq: params[:query],
                        library_name_cont: params[:query],
                        library_address_cont: params[:query]
                    }
                    if library
                        members = library.members.ransack(search_conditions.merge(m: 'or')).result
                        members = paginate(members)
                        present members, with: Api::Entities::Member
                    else
                        error!('Library not found', 404)
                    end
                else
                    error!({ error: "You are not authorized to perform this action" }, 401)
                end
            end

            resources :books do
                desc "Get all books for a specific library"
                params do
                    optional :page, type: Integer, desc: "Page number"
                    optional :per_page, type: Integer, desc: "Number of items per page"
                    optional :query, type: String, desc: "Search query"
                end
                get do
                    library = Library.find(params[:library_id])
                    book_inventories = library.book_inventories
                    search_conditions = {
                      title_cont: params[:query],
                      author_cont: params[:query],
                      published_at_cont: params[:query],
                      isbn_matches: params[:query],
                      genre_cont: params[:query],
                      copy_count_matches: params[:query]
                    }
                    books = Book.joins(:book_inventories).where(book_inventories: { id: book_inventories }).distinct
                    books = books.ransack(search_conditions.merge(m: 'or')).result
                    books = paginate(books)
                    present books, with: Api::Entities::Book, type: :full
                end
            end

            resources :book_inventories do
                # Return all book inventories for a specific library
                desc "Return list of book inventories for a library"
                params do
                    optional :page, type: Integer, desc: "Page number"
                    optional :per_page, type: Integer, desc: "Number of items per page"
                    optional :query, type: String, desc: "Search query"
                end
                get do
                    library = Library.find(params[:library_id])
                    if Current.user.admin? || (Current.user.librarian? && Current.library_id ==  params[:library_id])
                        search_conditions ={
                            id_eq: params[:query],
                            book_id_eq: params[:query],
                            library_id_eq: params[:query],
                            copies_borrowed_eq: params[:query],
                            copies_available_eq: params[:query],
                            copies_reserved_eq: params[:query]
                        }
                        if library
                            book_inventories = library.book_inventories
                            book_inventories = paginate(book_inventories)
                            present book_inventories, with: Api::Entities::BookInventory, type: :full
                        else
                            error!('Library not found', 404)
                        end
                    else
                        error!('You are not authorized to access this resource', 403)
                    end
                end

                # Create a book inventory
                desc "Create a new book inventory"
                params do
                    requires :book_id, type: Integer, desc: "Book ID"
                    requires :available_copies, type: Integer, desc: "Copies in stock"
                    requires :copies_borrowed, type: Integer, desc: "Copies borrowed"
                    requires :copies_reserved, type: Integer, desc: "Copies reserved"
                end
                post do
                    if Current.user.admin? || (Current.user.librarian? && Current.library_id == params[:library_id])
                        library = Library.find(params[:library_id])
                        book_inventory = library.book_inventories.new(params)
                        if book_inventory.save
                            present message: "Book inventory successfully created.", book_inventory: book_inventory, with: Api::Entities::BookInventory, type: :full
                        else
                            error!(book_inventory.errors.full_messages, 422)
                        end
                    else
                        error!('You are not authorized to perform this action', 401)
                    end
                end
        
                # Get a specific book inventory
                desc "Return a specific book inventory"
                params do
                    requires :inventory_id, type: Integer, desc: "Book Inventory ID"
                end
                get ':inventory_id' do
                    if Current.user.admin? ||  (Current.user.librarian? && Current.library_id == params[:library_id]) 
                        library = Library.find(params[:library_id])
                        book_inventory = library.book_inventories.find_by(id: params[:inventory_id])
                        if book_inventory
                            present book_inventory, with: Api::Entities::BookInventory
                        else
                            error!('Book inventory not found', 404)
                        end
                    else
                        error!('You are not authorized to perform this action', 401)
                    end
                end
        
                route_param :id do
                    # Edit book inventory details
                    desc "Edit a book inventory"
                    params do
                        optional :available_copies, type: Integer, desc: "Available Copies"
                        optional :copies_borrowed, type: Integer, desc: "Copies Borrowed"
                        optional :copies_reserved, type: Integer, desc: "Copies Reserved"
                    end
                    put do
                        if Current.user.admin? || (Current.user.librarian? && Current.library_id  == params[:library_id])
                            library = Library.find(params[:library_id])
                            book_inventory = library.book_inventories.find_by(id: params[:id])
                            if book_inventory
                                if book_inventory.update(params)
                                    present message: "Book Inventory Updated Successfully", book_inventory: book_inventory, with: Api::Entities::BookInventory, type: :full
                                else
                                    error!(book_inventory.errors.full_messages, 422)
                                end
                            else
                                error!('Book inventory not found', 404)
                            end
                        else
                            error!('You are not authorized to perform this action', 401)
                        end
                    end
            
                    # Delete a book inventory
                    desc "Delete a book inventory"
                    delete do
                        if Current.user.admin? || (Current.user.librarian? && Current.library_id  == params[:library_id])
                            library = Library.find(params[:library_id])
                            if library
                                book_inventory = library.book_inventories.find_by(id: params[:id])
                                if book_inventory
                                    book_inventory.destroy
                                    present message: "Book inventory successfully deleted."
                                else
                                    error!('Book inventory not found', 404)
                                end
                            else
                                error!('Library not found', 404)
                            end
                        else
                            error!('You are not authorized to perform this action', 401)
                        end
                    end
                end
            end


            resources :fine_rates do
                # Get all fine rates for a specific library
                desc "Get all fine rates for a specific library"
                params do
                    optional :page, type: Integer, desc: "Page number"
                    optional :per_page, type: Integer, desc: "Number of items per page"
                    optional :query, type: String, desc: "Search query"
                end
                get do
                    if Current.user.admin? || (Current.user.librarian? && Current.library_id  == params[:library_id])
                        library = Library.find(params[:library_id])
                        search_conditions ={
                            id_eq: params[:query],
                            fine_amount_cont: params[:query],
                            fine_type_cont: params[:query],
                            library_id_eq: params[:query]
                        }
                        if library
                            fine_rates = library.fine_rates.ransack(search_conditions.merge(m: 'or')).result
                            fine_rates = paginate(fine_rates)
                            present fine_rates, with: Api::Entities::FineRate, type: :full
                        else
                            error!('Library not found', 404)
                        end
                    else
                        error!('You are not authorized to perform this action', 401)
                    end
                end
            
                # Create a fine rate for a specific library
                desc "Create a fine rate for a specific library"
                params do
                    requires :fine_type, type: String, values: %w[overdue damaged], desc: "Fine type"
                    requires :fine_amount, type: Float, desc: "Rate for the fine type"
                end
                post do
                    if Current.user.admin? || Current.user.librarian?
                        library = Library.find(params[:library_id])
                        fine_rate = library.fine_rates.new(declared(params))
                        if fine_rate.save
                            present fine_rate, with: Api::Entities::FineRate, type: :full
                        else
                            error!(fine_rate.errors.full_messages, 422)
                        end
                    else
                        error!('You are not authorized to perform this action', 401)
                    end
                end
            
                # Update a fine rate for a specific library
                desc "Update a fine rate for a specific library"
                params do
                    requires :id, type: Integer, desc: "Fine Rate ID"
                    optional :fine_type, type: String, values: %w[overdue damaged], desc: "Fine type"
                    optional :fine_amount, type: Float, desc: "Rate for the fine type"
                end
                put ':id' do
                    if Current.user.admin? || Current.user.librarian?
                        library = Library.find(params[:library_id])
                        fine_rate = library.fine_rates.find(params[:id])
                        if fine_rate.update(declared(params, include_missing: false))
                            present fine_rate, with: Api::Entities::FineRate
                        else
                            error!(fine_rate.errors.full_messages, 422)
                        end
                    else
                        error!('You are not authorized to perform this action', 401)
                    end
                end
            
                # Delete a fine rate for a specific library
                desc "Delete a fine rate for a specific library"
                params do
                    requires :id, type: Integer, desc: "Fine Rate ID"
                end
                delete ':id' do
                    if Current.user.admin? || Current.user.librarian?
                        library = Library.find(params[:library_id])
                        fine_rate = library.fine_rates.find(params[:id])
                        fine_rate.destroy
                        present message: "Fine Rate is destroyed."
                    else
                        error!('You are not authorized to perform this action', 401)
                    end
                end
            end
        end
    end
end