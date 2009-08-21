-- $Id: types.s 4448 2009-01-20 23:55:50Z david $

BEGIN;
SELECT plan( 1 );
--SELECT * FROM no_plan();

SELECT pass('first pass!');

SELECT * FROM finish();
ROLLBACK;