/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. 

NOTES FOR SELF:
Bookings table has 5 fields.
    bookid- an integer field up to 4 characters. The primary field, 0-4042
    facid- an integer field 1 charachter. Ranges of 0 to 8
    memid- an integer field 2 charachters. Range of 0-36
    starttime- a datetime field, with a min of 2012-07-03 08:00:00 and a MAX of 2012-09-30 19:30:00
    slots- an interger field 2 characters. Range of 1-14

Facilities table has 7 fields.
    facid- an integer field 1 charachter. Ranges of 0 to 8. The primary field
    name- varchar field
    membercost- decimal field
    guestcost - decimal field
    initialoutlay - 5 character int
    monthlymaintenance - 4 character int
    priceCategory - text
    
Members tables has 8 fields.
    memid- the primary key
    surname
    firstname
    address
    zipcode
    telephone
    recommendedby
    joindate

*/


/* QUESTIONS*/ 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name 
FROM `Facilities` 
WHERE membercost=0


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(name) AS `Free_for_Members` 
FROM `Facilities` 
WHERE membercost=0


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 	facid,
	name,
	membercost,
	monthlymaintenance
FROM `Facilities`
WHERE (membercost < .2 * monthlymaintenance)
	AND (membercost > 0)

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM `Facilities` 
WHERE facid IN (1,5)


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name AS 'cheap',
	monthlymaintenance
FROM `Facilities`
WHERE priceCategory='cheap';

SELECT name AS 'expensive',
	monthlymaintenance
FROM `Facilities`
WHERE priceCategory='expensive';


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname,
	surname
FROM `Members`
WHERE joindate IN (
    SELECT MAX(joindate)
    FROM `Members`);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT CONCAT_WS(' ',firstname,surname) AS member_name
	,name AS tennis_court
FROM (SELECT DISTINCT memid,facid
	FROM Bookings
	WHERE facid IN(
    	SELECT DISTINCT facid
    	FROM Facilities
    	WHERE name LIKE 'Tennis Court%')
	) AS sub
INNER JOIN Facilities
USING (facid)
INNER JOIN Members
USING (memid)
ORDER BY member_name ASC,tennis_court;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name,
	CONCAT_WS(' ',firstname,surname)AS member_name,
	CASE
		WHEN memid = 0 THEN slots*guestcost
		ELSE slots * membercost
	END AS 'cost'
FROM Bookings
INNER JOIN Facilities
USING (facid)
INNER JOIN Members
USING (memid)
WHERE starttime LIKE '2012-09-14%'
	AND CASE
			WHEN (memid=0 AND slots*guestcost>30) THEN 1
			WHEN (memid<>0 AND slots*membercost>30) THEN 1
			ELSE 0
		END = 1
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT name AS facility_name,
	member_name,
	CASE
		WHEN memid=0 THEN slots*guestcost
		ELSE slots*membercost
	END AS cost
FROM (SELECT memid,facid,slots
	FROM Bookings
	WHERE starttime LIKE '2012-09-14%') as booked_day
INNER JOIN 
	(SELECT memid, CONCAT_WS(' ',firstname,surname) AS member_name
     FROM Members) AS members_list
USING (memid)
INNER JOIN Facilities
USING (facid)
WHERE CASE
	WHEN (memid=0 AND slots*guestcost>30) THEN 1
	WHEN (memid<>0 AND slots*membercost>30) THEN 1
	ELSE 0
END =1
ORDER BY cost desc;

/*Fun fact: this approach with subqueries takes 2 milliseconds longer than just JOINING all the tables directly first.*/


/* PART 2: SQLite */
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output. */
 
/*QUESTIONS:*/
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT name,
	SUM(cost_of_booking) AS revenue
FROM 
(SELECT facid,name,
	CASE
		WHEN memid=0 THEN slots*guestcost
		ELSE slots*membercost
	END as cost_of_booking
FROM Bookings
INNER JOIN Facilities
USING (facid)) AS sub
GROUP BY name
HAVING SUM(cost_of_booking)<1000
ORDER BY 2;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.surname, m1.firstname, m2.surname,m2.firstname
FROM Members AS m1
LEFT JOIN Members AS m2
ON m1.recommendedby=m2.memid
ORDER BY 1,2


/* Q12: Find the facilities with their usage by member, but not guests */

SELECT name, COUNT(*)
FROM Bookings
INNER JOIN Facilities
USING (facid)
WHERE memid<>0
GROUP BY facid;

/* Q13: Find the facilities usage by month, but not guests */
SELECT DISTINCT CASE
		WHEN starttime LIKE '2012-07-%' THEN '07'
		WHEN starttime LIKE '2012-08-%' THEN '08'
		WHEN starttime LIKE '2012-09-%' THEN '09'
		END as month,
	COUNT(*) AS member_facilities_usage
FROM Bookings
WHERE memid<>0
GROUP BY 1;
