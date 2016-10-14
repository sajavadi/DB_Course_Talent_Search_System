
/*
This view uses coauditions_verifier function to calculate all direct coaudition
tuples
*/
CREATE VIEW coauditions AS 
SELECT c1.contestant_id AS c1id, c2.contestant_id AS c2id 
FROM contestant c1, contestant c2
WHERE coauditions_verifier(c1, c2);