BEGIN;
SELECT plan( 1 );
--SELECT * FROM no_plan();

SELECT pass('first pass!');

SELECT * FROM finish();
ROLLBACK;
