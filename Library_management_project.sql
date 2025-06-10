-- Project task


-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 
-- 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category,
rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00,
'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- insert into table_name(column1--,column2,....column N) structure of insert statement
-- values(column1--,column2,....column N)


-- Task 2: Update an Existing Member's Address
update members
set member_address = '125 Main St'
where member_id = 'C101';
SELECT * FROM members;



SELECT * FROM issued_status;
SELECT * FROM return_status;




-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with 
-- issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status
WHERE issued_id = 'IS121';
delete from issued_status
where issued_id = 'IS121'


-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';



-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	ist.issued_member_id,
	m.member_name
	FROM issued_status as ist
join
members as m
on m.member_id = ist.issued_member_id
group by 1, 2
having count(ist.issued_id) > 1

select * from members
select * from issued_status


-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables 
-- based on query results - each book and total book_issued_cnt**\
create table book_cnts
as
select
	b.isbn,
	b.book_title,
	count(issued_id) as no_issued
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1, 2;

select * from book_cnts;

-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'


-- Task 8: Find Total Rental Income by Category:
select 
	b.category,
 	sum(b.rental_price) as Rental_Income,
	count(*)
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1


-- 9 . List Members Who Registered in the Last 180 Days:


INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C1180', 'sam', '145 Main St', '2025-04-01'),
('C11990', 'john', '133 Main St', '2025-03-01');
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'    
    


-- task 10 List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name as manager
FROM employees as e1
JOIN  
branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
CREATE TABLE books_price_greater_than_seven
AS    
SELECT * FROM Books
WHERE rental_price > 7

SELECT * FROM 
	rental_price_gaterthan_seven

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

    
SELECT * FROM return_status



/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30 

select * from books
select * from members
select * from issued_status
select * from return_status

select 
	m.member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	rs.return_date
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
join 
members as m
on ist.issued_member_id = m.member_id
left join
return_status as rs
on rs.issued_id = ist.issued_id

where 
	rs.return_date is null
	and
	(current_date - ist.issued_date) > 30
order by 1

/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/


select * from books
select * from return_status


-- manually
select * from issued_status
where issued_book_isbn = '978-0-330-25864-8'

select * from books
where isbn = '978-0-451-52994-2';


update books
set status = 'no'
where isbn = '978-0-451-52994-2';

select * from books
where isbn = '978-0-451-52994-2';

SELECT * FROM return_status
where  issued_id = 'IS130';




INSERT INTO return_status(return_id, issued_id, return_date)
VALUES
('RS125', 'IS130', CURRENT_DATE);
SELECT * FROM return_status
WHERE issued_id = 'IS130';

select * from return_status

update books
set status = 'yes'
where isbn = '978-0-451-52994-2';


-- Stored Procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql

AS $$

	DECLARE
	    v_isbn VARCHAR(50);
	    v_issued_book_name VARCHAR(80);
BEGIN
	-- all your logic and code..
	-- inserting into returns based on users input..
	INSERT INTO return_status(return_id, issued_id, return_date)
	VALUES
	(p_return_id, p_issued_id, CURRENT_DATE);
	SELECT
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_issued_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;


	update books
	set status = 'yes'
	where isbn = v_isbn;

	
	RAISE NOTICE 'Thank you for returning the book: %', v_issued_book_name;

END;
$$

-- calling function 
CALL add_return_records('RS148', 'IS140');


-- create Store Procedure

create or replace procedure add_return_issued_book(q_return_id VARCHAR(10), q_issued_id VARCHAR(10))
language plpgsql

as $$
	declare
		v_isbn VARCHAR(50);
		v_issued_book_name VARCHAR(80);

begin
	-- all logic or code here
	insert into return_status(return_id, issued_id, return_date)
	values
	(q_return_id , q_issued_id , current_date);
	select
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_issued_book_name
	FROM issued_status
	WHERE issued_id = q_issued_id;

	update books
	set status = 'yes'
	where isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_issued_book_name;
	
end
$$

call add_return_issued_book('RS138', 'IS135')


select * from books
where isbn =  'IS135'



/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned,
and the total revenue generated from book rentals.
*/


-- Branch performance report
-- each branch
-- number of books issued
-- number of books retured
-- total revenue generated from the book rentals

select * from books
select * from branch
select * from issued_status
select * from return_status


create table branch_reports
as
select
	b.branch_id,
	b.manager_id,
	count(ist.issued_id) as number_book_issued,
	count(rs.return_id) as number_of_book_return,
	sum(bk.rental_price) as total_revenue
from issued_status as ist
join
employees as e
on e.emp_id = ist.issued_emp_id
join
branch as b
on e.branch_id = b.branch_id
left join
return_status as rs
on rs.issued_id = ist.issued_id
join
books as bk
on ist.issued_book_isbn = bk.isbn
group by 1, 2;


select * from  branch_reports


/*
-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
-- containing members who have issued at least one book in the last 2 months.
*/

-- issued_status table..
-- member table..


select * from issued_status
select * from members




create table activate_members
as
select
	*
from issued_status as ist
join
members as mb
on ist.issued_member_id = mb.member_id

where ist.issued_date >= current_date - interval '2 month'

select 
	*
from  activate_members


CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;


insert into issued_status (issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
values
('IS143','C105','Quranul Qarim', '2025-03-05', '978-0-330-25864-8', 'E105'),
('IS144','C106','Hadith Sharif', '2025-09-05', '978-0-330-25864-8', 'E107')

select * from issued_status



-- 
-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.


-- branch 
-- employees
-- issued 

select * from branch
select * from employees
select * from issued_status


with ctes as(
select
	--*
 	b.branch_id,
	e.emp_id,
	e.emp_name,
	count(ist.issued_book_isbn) as number_of_book_proceed,
	b.branch_address
	
from branch as b
join 
employees as e
on e.branch_id = b.branch_id
join 
issued_status as ist
on e.emp_id = ist.issued_emp_id

group by 1,2

)

select
	emp_name,
	branch_address,
	number_of_book_proceed,	
	dense_rank() over(order by number_of_book_proceed desc) as rnk
from ctes
limit 3;




SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2






/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

*/


select * from books


select * from issued_status

create or replace procedure issue_book(p_issued_id varchar(10), p_issued_member_id varchar(30), p_issued_book_isbn varchar(30), p_issued_emp_id varchar(10))

language plpgsql

as $$

declare
-- all the variable
	v_status varchar(10);

begin
-- all the code
	-- checking if book is available
	select
		status
		into
		v_status
	from books
	where isbn = p_issued_book_isbn;

	if v_status = 'yes' then
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		update books
			set status = 'no'
		where isbn = p_issued_book_isbn;

		
        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;

	 ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
		


end

$$



SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');



CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');


CALL issue_book('IS158', 'C109', '978-0-375-41398-6', 'E105');

SELECT * FROM books
WHERE isbn = '978-0-553-29698-2'

SELECT * FROM books
WHERE isbn = '978-0-375-41398-6'


