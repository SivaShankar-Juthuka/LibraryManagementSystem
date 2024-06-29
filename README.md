# Library Management System

This project focuses on managing libraries and their books borrowings and requests. The system has three different roles:
1. Admin
2. Librarian
3. Member (considered as a student)

## Admin Responsibilities
1. Assign signed-up users as Librarians or Members.
2. Add libraries to the system and perform CRUD operations.
3. Add books to the Global Inventory, which is available for all libraries, and perform CRUD operations.
4. Create fines for members due to "overdue" and "damage."
5. Monitor all Book Inventories for every library.
6. Monitor all Borrowing histories of every member in all libraries.
7. Monitor all Request histories of every member in all libraries.
8. Monitor all Members of all libraries.
9. Monitor all Librarians of all libraries.
10. Monitor all Libraries of all libraries.
11. Monitor all Books of all libraries.
12. Monitor all fine histories of members of all libraries.

## Librarian Responsibilities
1. Add books to their library and create a number of BookCopies for the books.
2. Manage the Borrowing of books based on requests made by members in their library.
3. Monitor the borrowing histories of members in their library.
4. Monitor the requests made by members in their library.
5. Collect fines and create a history of imposed fines.
6. Monitor the books in their library.

## Member Responsibilities
1. Check the books in their library.
2. Request a book from their library.
3. Borrow a book from their library.
4. Return a book to their library.

## Description
The workflow is as follows:
Once a user signs up, they don't have any permissions until an admin assigns them as a librarian or member.

### If the user is assigned as a member:
- They can check and request books in their library.
- When a book is requested, the Book Inventory for that library is automatically updated (copies_reserved increments by one).
- Members can monitor their borrowing history, request history, and fine history.

### If the user is assigned as a librarian:
- They can add books to their library and create BookCopies for those books.
- Manage the Borrowing of books based on requests from members in their library. Once a request is approved, a borrow record is created with `returned_at` field as null. The Book Inventory for that library is updated (copies_reserved decrements by one, copies_borrowed increments by one, and available copies decrements by one). The BookCopy's `is_available` field is set to false.
- When returning a book, the librarian enters the `returned_at` date. If the book is damaged, they set the `is_damaged` field to true, automatically imposing a fine based on the library's damage fine rate. The BookCopy is marked as damaged and unavailable.
- If the book is not damaged, the borrow record is updated with `returned_at` and the Book Inventory is updated (copies_borrowed decrements by one, available_copies increments by one). The BookCopy's `is_available` field is set to true.
- Before returning, the due_date is checked. If overdue, a fine is imposed based on the overdue fine rate multiplied by the number of overdue days.
