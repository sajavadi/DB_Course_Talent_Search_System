 
/*
QUERY 1

Find all pairs of contestants who happened to audition 
the same piece during the same show 
and got the same score from at least one judge. 
*/

SELECT cid2cname(a1.contestant), cid2cname(a2.contestant) 		-- convert contestant_id to contestant_name
FROM audition a1, audition a2									-- there exists a1, a2 such that
WHERE a1.contestant != a2.contestant AND						-- not the same contestant performed at both
a1.piece = a2.piece AND											-- the same piece was performed however
a1.show = a2.show AND											-- at the same show
received_same_score(a1, a2) AND 								-- they received the same score from at least one judge
a1.contestant > a2.contestant;									-- remove duplicate pairs

/*
QUERY 2

Find all pairs of contestants who happened to audition 
the same piece (in possibly different shows) and got 
the same average score for that piece. 
*/

SELECT cid2cname(a1.contestant), cid2cname(a2.contestant)		-- convert contestant_id to contestant_name
FROM audition a1, audition a2									-- there exists a1, a2 such that
WHERE a1.contestant != a2.contestant AND						-- not the same contestant performed at both
a1.piece = a2.piece AND											-- the same piece was performed however
average_audition_score(a1) = average_audition_score(a2) AND		-- and their average score was the same
a1.contestant > a2.contestant;									-- remove duplicate pairs

/*
QUERY 3

Find all pairs of contestants who auditioned the same piece in 
(possibly different) shows that had at least 3 judges and the two 
contestants got the same highest score.
*/


SELECT cid2cname(a1.contestant), cid2cname(a2.contestant)		-- convert contestant_id to contestant_name
FROM audition a1, audition a2									-- there exists c1, c2, a1, a2 such that
WHERE a1.contestant != a2.contestant AND						-- not the same contestant performed at both
a1.piece = a2.piece AND 										-- the same piece was performed however
max_audition_score(a1) = max_audition_score(a2) AND				-- and the maximum score they received was the same
judge_count(a1) >= 3 AND 										-- at least three judges were present for a1
judge_count(a2) >= 3 AND										-- at least three judges were present for a2 
a1.contestant > a2.contestant;									-- remove duplicate pairs


/*
QUERY 4a

Find all pairs of contestants such that the first contestants 
has performed all the pieces of the second contestant 
(possibly in different shows).
*/

SELECT c1.contestant_name, c2.contestant_name
FROM contestant c1, contestant c2								-- there exists c1, c2 such that
WHERE c1.contestant_id != c2.contestant_id AND					-- not the same contestant
NOT c2_performed_piece_c1_didnt(c1, c2);						-- and there is no such piece that c2 performed and c1 didn't


/*

Query 5

Find all chained co-auditions. A chained co-auditions is the transitive closure of the following
binary relation: X and Y (directly) co-auditioned if they both performed the same piece in the
same show and got the same score from at least one (same) judge. Thus, a chained co-audition
can be either a direct or an indirect co-audition.
*/
WITH RECURSIVE chained_coauditions(c1id, c2id) AS (
	SELECT * FROM coauditions									-- base case
UNION ALL														-- UNION
	SELECT c.c1id, cc.c2id										-- recursive case
	FROM coauditions c, chained_coauditions cc					-- recursive case
	WHERE c.c2id = cc.c1id 										-- recursive case
)
SELECT cid2cname(c1id), cid2cname(c2id) 						-- select from recursive view
FROM chained_coauditions;