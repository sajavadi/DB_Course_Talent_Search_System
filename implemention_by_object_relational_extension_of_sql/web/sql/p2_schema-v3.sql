
 /*
	Drop Database/Type/Table queries
	this is for clearing table only
	when changing schema to make it painless
	
	DROP DATABASE IF EXISTS "Talent_Sys";
	DROP TYPE IF EXISTS contestanttype CASCADE;
	DROP TYPE IF EXISTS judgetype CASCADE;
	DROP TYPE IF EXISTS piecetype CASCADE;
	DROP TYPE IF EXISTS showtype CASCADE;
	DROP TYPE IF EXISTS showjudgestype CASCADE;
	DROP TYPE IF EXISTS auditiontype CASCADE;
	DROP TYPE IF EXISTS scoretype CASCADE;
	DROP TABLE IF EXISTS contestant CASCADE;
	DROP TABLE IF EXISTS judge CASCADE;
	DROP TABLE IF EXISTS piece CASCADE;
	DROP TABLE IF EXISTS show CASCADE;
	DROP TABLE IF EXISTS showjudges CASCADE;
	DROP TABLE IF EXISTS audition CASCADE;
	DROP TABLE IF EXISTS score CASCADE;
*/

/* Contestant table related commands */
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
WITH OIDS;

ALTER TABLE score 
	ADD CONSTRAINT score_pk PRIMARY KEY (audition, judge); 

ALTER TABLE score
  ADD CONSTRAINT score_fk1 FOREIGN KEY (audition) REFERENCES Audition(audition_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE score
  ADD CONSTRAINT audition_fk2 FOREIGN KEY (judge) REFERENCES Judge(judge_id) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE UNIQUE INDEX score_idx ON score (audition, judge);
