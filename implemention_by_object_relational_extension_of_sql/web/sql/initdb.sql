/*
 * Brief description: This file combines all other sql files to create all 
 *   the required entities in the database.
 *   It includes the following steps:
 *      First step: Creating database
 *      Second step: Creating types, tables, indices and defining constraints
 *      Third step:  Creating functions  
 *      Fourth step: Creating views 
 *      Fifth step: Inserting test data
 */

/*
First step: Creating database and dedicated user
*/
DROP DATABASE IF EXISTS Talent_Sys;
CREATE DATABASE Talent_Sys;

CREATE USER talent_manager WITH PASSWORD 'C0mputer5cience';
GRANT ALL PRIVILEGES ON DATABASE "Talent_Sys" TO talent_manager;

/*
Second step: Creating types, tables, indices and defining constraints
*/

CREATE TYPE ContestantType AS (
	contestant_id INTEGER,
	contestant_name VARCHAR(40)
);

CREATE TABLE CONTESTANT OF ContestantType 
WITH OIDS;

ALTER TABLE contestant
  ADD CONSTRAINT contestant_pk PRIMARY KEY (contestant_id);

CREATE UNIQUE INDEX contestant_idx ON contestant (contestant_id);

/* Piece table related commands */
CREATE TYPE PieceType AS (
	piece_id INTEGER,
	piece_name VARCHAR(40)
);
 
CREATE TABLE PIECE OF PieceType 
WITH OIDS;

ALTER TABLE piece
  ADD CONSTRAINT piece_pk PRIMARY KEY (piece_id);

CREATE UNIQUE INDEX piece_idx ON piece (piece_id);


/* Judge table relatd commands */
CREATE TYPE JudgeType AS (
	judge_id INTEGER,
	judge_name VARCHAR(40)
);

CREATE TABLE JUDGE OF JudgeType 
WITH OIDS;

ALTER TABLE judge
  ADD CONSTRAINT judge_pk PRIMARY KEY (judge_id);

CREATE UNIQUE INDEX judge_idx ON judge (judge_id);

/* Show table related commands */
CREATE TYPE ShowType AS (
	show_id INTEGER,
	show_date DATE
);
 
CREATE TABLE SHOW OF ShowType 
WITH OIDS;

ALTER TABLE show
  ADD CONSTRAINT show_pk PRIMARY KEY (show_id);

CREATE UNIQUE INDEX show_idx ON show(show_id);

/* ShowJudges related commands */
CREATE TYPE ShowJudgesType AS(
	show INTEGER, --show_id
	judge INTEGER --judge_id
);
 
CREATE TABLE SHOWJUDGES OF ShowJudgesType
--FOREIGN KEY (show) REFERENCES SHOW (show_id),
--FOREIGN KEY (judge) REFERENCES AUDITION (judge_id),
WITH OIDS;

ALTER TABLE showjudges
  ADD CONSTRAINT showjudges_pk PRIMARY KEY (show, judge);

ALTER TABLE showjudges
  ADD CONSTRAINT showjudges_fk1  FOREIGN KEY (show) REFERENCES Show(show_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE showjudges
  ADD CONSTRAINT showjudges_fk2  FOREIGN KEY (judge) REFERENCES Judge(judge_id) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE UNIQUE INDEX showjudges_idx ON showjudges (show,judge);

/* Audition table related commands */
CREATE TYPE AuditionType AS (
	audition_id INTEGER,
	contestant INTEGER, --contestant_id
	piece INTEGER, --piece_id
	show INTEGER --show_id
);

CREATE TABLE AUDITION OF AuditionType
--FOREIGN KEY (contestant) REFERENCES CONTESTANT (contestant_id),
--FOREIGN KEY (piece) REFERENCES PIECE (piece_id),
--FOREIGN KEY (show) REFERENCES SHOW (show_id),
WITH OIDS;

ALTER TABLE audition 
	ADD CONSTRAINT audition_pk PRIMARY KEY (audition_id); 

ALTER TABLE audition
  ADD CONSTRAINT audition_fk1 FOREIGN KEY (contestant) REFERENCES Contestant(contestant_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE audition
  ADD CONSTRAINT audition_fk2 FOREIGN KEY (piece) REFERENCES Piece(piece_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE audition
  ADD CONSTRAINT audition_fk3 FOREIGN KEY (show) REFERENCES Show(show_id) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE UNIQUE INDEX audition_idx ON audition (audition_id);

/*Score Table related commands */
CREATE TYPE ScoreType AS (
	audition INTEGER, --audition_id
	judge INTEGER, --judge_id
	score INTEGER
);

CREATE TABLE SCORE OF ScoreType
--FOREIGN KEY (audition) REFERENCES AUDITION (audition_id),
--FOREIGN KEY (judge) REFERENCES AUDITION (judge_id),
WITH OIDS;

ALTER TABLE score 
	ADD CONSTRAINT score_pk PRIMARY KEY (audition, judge); 

ALTER TABLE score
  ADD CONSTRAINT score_fk1 FOREIGN KEY (audition) REFERENCES Audition(audition_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE score
  ADD CONSTRAINT audition_fk2 FOREIGN KEY (judge) REFERENCES Judge(judge_id) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE UNIQUE INDEX score_idx ON score (audition, judge);

/*
Step 2.1 Giving our dedicated user select permissions
*/
GRANT SELECT ON ALL TABLES IN SCHEMA public TO talent_manager;

/*
Third step:  Creating functions
*/

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
	FROM piece p, audition a
	WHERE a.piece = p.piece_id AND
	a.contestant = c2.contestant_id AND
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

-- Used for Query 5 
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


/*
Fourth step: Creating views 
*/
CREATE VIEW coauditions AS 
SELECT c1.contestant_id AS c1id, c2.contestant_id AS c2id 
FROM contestant c1, contestant c2
WHERE coauditions_verifier(c1, c2);

/*
Fifth step: Inserting test data
*/


-- (contestant_id, contestant_name)
INSERT INTO contestant VALUES 
( 1, 'Joe'),
( 2, 'Bob'),
( 3, 'Mary'),
( 4, 'Ann'),
( 5, 'Bess'),
( 6, 'Tom'),
( 7, 'Don');

-- (piece_id, piece_name)
INSERT INTO piece VALUES
( 1, 'Barcarolle'),
( 2, 'Giselle'),
( 3, 'The Tramp'),
( 4, 'Besame Mucho'),
( 5, 'Swan Lake'),
( 6, 'The Habanera');

-- (judge_id, judge_name)
INSERT INTO judge VALUES 
( 1, 'Judy'),
( 2, 'Lucy'),
( 3, 'Irving'),
( 4, 'Phil'),
( 5, 'Oscar'); 

-- (show_id, show_date)
INSERT INTO show VALUES
( 1, '02/02/2014'),
( 2, '04/02/2014'),
( 3, '06/02/2014'),
( 4, '08/02/2014'),
( 5, '10/05/2014');

-- (show, judge)
INSERT INTO showjudges VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 4),
(3, 3),
(3, 4),
(3, 5),
(4, 2),
(4, 5),
(5, 2),
(5, 3),
(5, 4);

-- (audition_id, contestant, piece, show)
INSERT INTO audition VALUES
(1, 1, 1, 1),
(2, 3, 1, 1),
(3, 3, 2, 1),
(4, 5, 4, 1),
(5, 7, 4, 1),
(6, 7, 5, 1),
(7, 2, 5, 2),
(8, 3, 6, 2),
(9, 3, 4, 2),
(10, 4, 6, 2),
(11, 5, 2, 2),
(12, 6, 4, 2),
(13, 6, 3, 2),
(14, 2, 3, 3),
(15, 4, 4, 3),
(16, 5, 5, 3),
(17, 6, 1, 3),
(18, 7, 2, 3),
(19, 1, 3, 4),
(20, 2, 1, 4),
(21, 4, 4, 4),
(22, 6, 3, 4),
(23, 6, 1, 4),
(24, 2, 5, 5),
(25, 2, 2, 5),
(26, 3, 1, 5),
(27, 3, 4, 5),
(28, 4, 4, 5),
(29, 5, 4, 5),
(30, 5, 6, 5),
(31, 6, 3, 5),
(32, 7, 3, 5);

-- (audition, judge, show)
INSERT INTO score VALUES
(1,  1, 7),
(1,  2, 8),
(1,  3, 6),
(2,  1, 5),
(2,  2, 6),
(2,  3, 6),
(3,  1, 9),
(3,  2, 6),
(3,  3, 8),
(4,  1, 4),
(4,  2, 5),
(4,  3, 6),
(5,  1, 9),
(5,  2, 9),
(5,  3, 7),
(6,  1, 7),
(6,  2, 7),
(6,  3, 10),
(7,  1, 8),
(7,  4, 6),
(8,  1, 3),
(8,  4, 5),
(9,  1, 9),
(9,  4, 10),
(10, 1, 7),
(10, 4, 6),
(11, 1, 8),
(11, 4, 7),
(12, 1, 5),
(12, 4, 5),
(13, 1, 7),
(13, 4, 6),
(14, 3, 8),
(14, 4, 7),
(14, 5, 9),
(15, 3, 7),
(15, 4, 6),
(15, 5, 4),
(16, 3, 6),
(16, 4, 8),
(16, 5, 7),
(17, 3, 9),
(17, 4, 7),
(17, 5, 6),
(18, 3, 8),
(18, 4, 6),
(18, 5, 9),
(19, 2, 7),
(19, 5, 6),
(20, 2, 6),
(20, 5, 8),
(21, 2, 9),
(21, 5, 8),
(22, 2, 8),
(22, 5, 10),
(23, 2, 5),
(23, 5, 5),
(24, 2, 3),
(24, 3, 5),
(24, 4, 6),
(25, 2, 4),
(25, 3, 6),
(25, 4, 8),
(26, 2, 5),
(26, 3, 7),
(26, 4, 10),
(27, 2, 6),
(27, 3, 8),
(27, 4, 7),
(28, 2, 7),
(28, 3, 9),
(28, 4, 6),
(29, 2, 9),
(29, 3, 8),
(29, 4, 8),
(30, 2, 8),
(30, 3, 7),
(30, 4, 10),
(31, 2, 6),
(31, 3, 6),
(31, 4, 8),
(32, 2, 5),
(32, 3, 8),
(32, 4, 7);


