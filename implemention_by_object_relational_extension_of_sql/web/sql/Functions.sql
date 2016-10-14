 -- Used for Query 1
 -- Checks to see if the two auditions have a score in common from the same judge
 -- This does NOT check if the show or piece are the same, that is the perogative of
 -- whatever function/query calls this
CREATE OR REPLACE FUNCTION received_same_score(a1 AuditionType, a2 AuditionType)
	RETURNS BOOLEAN AS $$
DECLARE temp_ret INTEGER;
BEGIN
	SELECT INTO temp_ret COUNT(*)
	FROM score s1, score s2
	WHERE s1.audition = a1.audition_id AND
	s2.audition = a2.audition_id AND
	s1.judge = s2.judge AND
	s1.score = s2.score;
	IF temp_ret > 0 THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
END;
$$ LANGUAGE plpgsql;
 
 -- Used for Query 2
 -- Computes the average score a contestant received for a particular audition
CREATE OR REPLACE FUNCTION average_audition_score(a AuditionType)
	RETURNS FLOAT AS $$
DECLARE ret FLOAT;
BEGIN
	SELECT INTO ret AVG(s.score)
	FROM score s
	WHERE s.audition = a.audition_id;
	RETURN ret;
END;
$$ LANGUAGE plpgsql;

-- Used for Query 3
-- Computes the maximum score a contestant received for a particular audition
CREATE OR REPLACE FUNCTION max_audition_score(a AuditionType)
	RETURNS INTEGER AS $$
DECLARE ret INTEGER;
BEGIN
	SELECT INTO ret MAX(s.score)
	FROM score s
	WHERE s.audition = a.audition_id;
	RETURN ret;
END;
$$ LANGUAGE plpgsql;

-- Used for Query 3
-- Computes the number of judges for a particular audition
CREATE OR REPLACE FUNCTION judge_count(a AuditionType)
	RETURNS INTEGER AS $$
DECLARE ret INTEGER;
BEGIN
	SELECT INTO ret COUNT(*)
	FROM showjudges s
	WHERE s.show = a.show;
	RETURN ret;
END;
$$ LANGUAGE plpgsql;

-- Used for Query 4a
-- Determines whether or not a contestant performed a particular piece in any show
CREATE OR REPLACE FUNCTION contestant_performed_piece(c ContestantType, p PieceType)
	RETURNS BOOLEAN AS $$
DECLARE temp_ret INTEGER;
BEGIN
	SELECT INTO temp_ret COUNT(*)
	FROM audition a
	WHERE a.piece = p.piece_id AND
	a.contestant = c.contestant_id;
	IF temp_ret > 0 THEN
		RETURN true;
	ELSE
		RETURN false;	
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Used for Query 4a
-- Determines whether there exists at least one piece that contestant 2 performed 
-- and contestant 1 didn't
CREATE OR REPLACE FUNCTION c2_performed_piece_c1_didnt(c1 ContestantType, c2 ContestantType)
	RETURNS BOOLEAN AS $$
DECLARE temp_ret INTEGER;
BEGIN
	SELECT INTO temp_ret COUNT(*)
	FROM piece p
	WHERE contestant_performed_piece(c2, p) AND
	NOT contestant_performed_piece(c1, p);
	IF temp_ret > 0 THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Used for Query 5
-- Determines whether contestant 1 and contestant 2 are indeed coauditioners
CREATE OR REPLACE FUNCTION coauditions_verifier(c1 ContestantType, c2 ContestantType)
	RETURNS BOOLEAN AS $$
	DECLARE temp_ret INTEGER;
	BEGIN
	SELECT INTO temp_ret COUNT(*)
	FROM audition a1, audition a2
	WHERE 
		c1.contestant_id < c2.contestant_id AND
		a1.contestant = c1.contestant_id AND
		a2.contestant = c2.contestant_id AND
		a1.show = a2.show AND
		a1.piece = a2.piece AND
		EXISTS
		(SELECT * FROM score s1, score s2
		       WHERE
			s1.audition = a1.audition_id AND
			s2.audition = a2.audition_id AND
			s1.judge = s2.judge AND
			s1.score = s2.score 
		);
	IF temp_ret > 0 THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Used for Queries 1, 2, 3, and 5 
-- Converts contestant_id to contestant_name
CREATE OR REPLACE FUNCTION cid2cname(cid INTEGER)
	RETURNS VARCHAR(40) AS $$
DECLARE ret VARCHAR(40);
BEGIN
	SELECT INTO ret contestant_name
	FROM contestant
	WHERE contestant_id = cid;
	RETURN ret;
END;
$$ LANGUAGE plpgsql;

