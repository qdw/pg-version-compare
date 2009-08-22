BEGIN;
SELECT plan( 6 );
--SELECT * FROM no_plan();

/****************************************************************************/
-- What does the major_versions() function look like?

SELECT has_function( 'public'::name, 'major_versions'::name );
SELECT function_lang_is( 'major_versions', 'sql' );
SELECT function_returns( 'major_versions', 'setof text' );
SELECT volatility_is( 'major_versions', 'stable' );

-- Now give it a try. Use the real data.
PREPARE have AS SELECT * FROM major_versions();
PREPARE want AS
 SELECT super::TEXT || '.' || major::TEXT
   FROM versions
  GROUP BY super, major
  ORDER BY super, major;

SELECT results_eq( 'have', 'want', 'major_versions() should return expected query values' );

-- Make sure that we actually *have* data.
DEALLOCATE want;
PREPARE want AS VALUES ('8.0'), ('8.1'), ('8.2'), ('8.3'), ('8.4');

SELECT results_eq( 'have', 'want', 'major_versions() should return actual values' );

SELECT * FROM finish();
ROLLBACK;
