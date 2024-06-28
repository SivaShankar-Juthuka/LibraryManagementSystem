class User < ApplicationRecord
    has_secure_password
  
    VALID_EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/
  
    validates :user_name, presence: true, uniqueness: true, on: [:signup, :login]
    validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX, message: "Please enter a valid email address." }
    validates :password, presence: true, length: { minimum: 6 }, on: [:signup, :login]

    def self.assign_librarian(user_id, library_id)
        user = User.find_by(id: user_id)
        library = Library.find_by(id: library_id)
        unless user && library
          error!({ message: "Invalid user or library" }, 404)
        end
        if user.member_for_library?(library_id)
          error!({ message: "User is already assigned as a member to this library" }, 422)
        end
        librarian = Librarian.new(user_id: user.id, library_id: library.id)
        unless librarian.save
          error!({ message: librarian.errors.full_messages.join(", ") }, 422)
        end
        user.update(is_assigned: true)
        librarian
    end
      
    def self.assign_member(user_id, library_id)
        user = User.find_by(id: user_id)
        library = Library.find_by(id: library_id)
        unless user && library
          error!({ message: "Invalid user or library" }, 404)
        end
        if user.librarian_for_library?(library_id)
          error!({ message: "User is already assigned as a librarian to this library" }, 422)
        end
        member = Member.new(user_id: user.id, library_id: library.id, borrowing_limit: BORROW_LIMIT)
        unless member.save
          error!({ message: member.errors.full_messages.join(", ") }, 422)
        end
        user.update(is_assigned: true)
        member
    end
      
    def admin?
        Current.user.present? && Admin.exists?(user_id: Current.user.id)
    end

    def librarian?
        Current.user.present? && Librarian.exists?(user_id: Current.user.id)
      end

    def member?
        Current.user.present? && Member.exists?(user_id: Current.user.id)
    end
    
    def librarian_for_library?(library_id)
        Librarian.exists?(user_id: self.id, library_id: library_id)
    end

    def member_for_library?(library_id)
        Member.exists?(user_id: self.id, library_id: library_id)
    end

    def self.ransackable_attributes
        %w[id email user_name is_assigned]
    end
end
  