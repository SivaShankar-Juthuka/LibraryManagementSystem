# app/api/v1/books.rb
class Api::V1::Books < Grape::API
    resource :books do
        before do
            authenticate!
        end

        resources :book_copies do
            desc "Return all book copies"
            params do
                optional :page, type: Integer, desc: "Page number"
                optional :per_page, type: Integer, desc: "Number of items per page"
                optional :query, type: String, desc: "Search query"
            end
            get do
                if Current.user.admin?
                    search_conditions = {
                        id_eq: params[:query],
                        book_id_eq: params[:query],
                        copy_number_eq: params[:query],
                        is_damaged_matches: params[:query], 
                        is_available_matches: params[:query]
                    }
                    book_copies = BookCopy.ransack(search_conditions.merge(m: 'or')).result
                    book_copies = paginate(book_copies)
                    present book_copies, with: Api::Entities::BookCopy, type: :full
                else
                    error!('Unauthorized access', 401)
                end
            end
        end

        # Return all books
        desc "Return list of books"
        params do
            optional :page, type: Integer, desc: "Page number"
            optional :per_page, type: Integer, desc: "Number of items per page"
            optional :query, type: String, desc: "Search query"
        end
        get do
            if Current.user.admin? || Current.user.librarian?
                search_conditions = {
                    title_cont: params[:query],
                    author_cont: params[:query],
                    published_at_cont: params[:query],
                    isbn_matches: params[:query],
                    genre_cont: params[:query],
                    copy_count_matches: params[:query]
                }
                books = Book.ransack(search_conditions.merge(m: 'or')).result
                books = paginate(books)
                present books, with: Api::Entities::Book, type: :full
            else
                error!('Unauthorized', 401)
            end
        end
    
        # Create a book
        desc "Create a new book"
        params do
            requires :title, type: String, desc: "Book Title"
            requires :author, type: String, desc: "Book Author"
            requires :isbn, type: String, desc: "Book ISBN number"
            requires :genre, type: String, desc: "Book Genre"
            requires :copy_count, type: Integer, desc: "Book copy count"
            requires :published_at, type: Integer, desc: "Book Published date"
        end
        post do
            if Current.user.admin? 
                book = Book.new(params)
                if book.save
                    present book, with: Api::Entities::Book, type: :full
                else
                    error!(book.errors.full_messages, 422)
                end
            else
                error!('Unauthorized', 401)
            end
        end
    

        route_param :book_id do
            # Get a specific book
            desc "Return a specific book"
            get do
                if Current.user.admin? || Current.user.librarian?
                    book = Book.find(params[:book_id])
                    if book
                        present book, with: Api::Entities::Book
                    else
                        error!('Book not found', 404)
                    end
                else
                    error!('Unauthorized', 401)
                end
            end
        
            # Edit book details 
            desc "Edit a book"
            params do
                requires :book_id, type: Integer, desc: "Book ID"
                optional :title, type: String, desc: "Book Title"
                optional :author, type: String, desc: "Book Author"
                optional :isbn, type: String, desc: "Book ISBN number"
                optional :genre, type: String, desc: "Book Genre"
                optional :copy_count, type: Integer, desc: "Book copy count"
                optional :published_at, type: Date, desc: "Book Published date"
            end
            put do
                if Current.user.admin?
                    book = Book.find_by(id: params[:book_id])
                    if book
                        update_params = declared(params, include_missing: false).except(:book_id)
                        if book.update(update_params)
                            present book, with: Api::Entities::Book
                        else
                            error!(book.errors.full_messages, 422)
                        end
                    else
                        error!('Book not found', 404)
                    end
                else
                    error!('Unauthorized', 401)
                end
            end
        
            # Delete a book
            desc "Delete a book"
            delete do
                if Current.user.admin?
                    book = Book.find(params[:book_id])
                    if book
                        book.destroy
                        present message: "Book is successfully deleted."
                    else
                        error!('Book not found', 404)
                    end
                else
                    error!('Unauthorized', 401)
                end
            end
        end
    end
end