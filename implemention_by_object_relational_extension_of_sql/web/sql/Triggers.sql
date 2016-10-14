/* 
 *   Brief description: 
 *	These are the triggers used before finding a better way to defining
 *      primary and foriegn key constraints using "ALTER TABLE" command. 
 *	
 */


CREATE OR REPLACE FUNCTION CheckShowJudges() RETURNS TRIGGER AS $CheckShowJudges$
    BEGIN
        -- Check that show and judge are given
        IF NEW.show IS NULL THEN
            RAISE EXCEPTION 'show cannot be null';
        END IF;
        IF NEW.judge IS NULL THEN
            RAISE EXCEPTION 'Show % cannot have null judge', NEW.show;
        END IF;

        -- Check for repetitive (show, judge) 
        IF EXISTS(SELECT * FROM showjudges as sj WHERE sj.show = NEW.show AND sj.judge = NEW.judge) THEN
            RAISE EXCEPTION 'The new tuple (% , %) is repetitive ', NEW.show, NEW.judge;
        END IF;

        -- Check the foreign key constraints
        IF NOT EXISTS (SELECT * FROM show WHERE show.show_id = NEW.show) THEN
            RAISE EXCEPTION '% is not an id of a show in the show table ', NEW.show;
	END IF;
	IF NOT EXISTS (SELECT * FROM judge WHERE judge.judge_id = NEW.judge) THEN
            RAISE EXCEPTION '% is not an id of a judeg in the judge table ', NEW.judge;
	END IF;
		
        RETURN NEW;
    END;
$CheckShowJudges$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS CheckShowJudges ON showjudges;

CREATE TRIGGER CheckShowJudges BEFORE INSERT OR UPDATE ON showjudges
    FOR EACH ROW EXECUTE PROCEDURE CheckShowJudges();

/*
Defining required triger fo audition table
*/	
CREATE OR REPLACE FUNCTION CheckAudition() RETURNS TRIGGER AS $CheckAudition$
    BEGIN
        -- Check inputs not being null
	IF NEW.audition_id IS NULL THEN
            RAISE EXCEPTION 'auddition_id cannot be null';
	END IF;
	IF NEW.contestant IS NULL THEN
            RAISE EXCEPTION 'contestant cannot be null';
	END IF;
	IF NEW.piece IS NULL THEN
            RAISE EXCEPTION 'piece cannot be null';
	END IF;
	IF NEW.show IS NULL THEN
            RAISE EXCEPTION 'show cannot be null';
	END IF;
	IF NOT EXISTS (SELECT * FROM contestant WHERE contestant.contestant_id = NEW.contestant) THEN
            RAISE EXCEPTION '% is not an id of a contestant in the contestant table ', NEW.contestant;
	END IF;
	IF NOT EXISTS (SELECT * FROM piece WHERE piece.piece_id = NEW.piece) THEN
            RAISE EXCEPTION '% is not an id of a peice in the piece table ', NEW.contestant;
	END IF;
	IF NOT EXISTS (SELECT * FROM show WHERE show.show_id = NEW.show) THEN
            RAISE EXCEPTION '% is not an id of a show in the show table ', NEW.show;
	END IF;
		
        RETURN NEW;
    END;
$CheckAudition$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS CheckAudition ON audition;

CREATE TRIGGER CheckAudition BEFORE INSERT OR UPDATE ON audition
    FOR EACH ROW EXECUTE PROCEDURE CheckAudition();	

/*
Defining required trigger for Score table
*/
CREATE OR REPLACE FUNCTION CheckScore() RETURNS TRIGGER AS $CheckScore$
    BEGIN
        -- Check inputs not being null
	IF NEW.audition IS NULL THEN
            RAISE EXCEPTION 'auddition cannot be null';
	END IF;
	IF NEW.judge IS NULL THEN
            RAISE EXCEPTION 'judge cannot be null';
	END IF;
	IF NEW.score IS NULL THEN
            RAISE EXCEPTION 'score cannot be null';
	END IF;
	IF NEW.score < 0 THEN
            RAISE EXCEPTION 'score cannot be less thant 0';
        END IF;
	IF NOT EXISTS (SELECT * FROM audition WHERE audition.audition_id = NEW.audition) THEN
		RAISE EXCEPTION '% is not an id of a audition in the audition table ', NEW.audition;
	END IF;
	IF NOT EXISTS (SELECT * FROM judge WHERE judge.judge_id = NEW.judge) THEN
            RAISE EXCEPTION '% is not an id of a judge in the judge table ', NEW.judge;
	END IF;
			
        RETURN NEW;
    END;
$CheckScore$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS CheckScore ON score;

CREATE TRIGGER CheckScore BEFORE INSERT OR UPDATE ON score
    FOR EACH ROW EXECUTE PROCEDURE CheckScore();