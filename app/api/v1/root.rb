class Api::V1::Root < Grape::API
    helpers AuthHelper
    helpers UserHelper
    helpers PaginationHelper    
    mount Api::V1::Users


    mount Api::V1::Books
    mount Api::V1::Libraries
    mount Api::V1::Borrows
    mount Api::V1::Requests
    mount Api::V1::Fines
end