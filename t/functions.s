BEGIN;
SELECT plan( 24 );
--SELECT * FROM no_plan();

/****************************************************************************/
-- What does the major_versions() function look like?
SELECT has_function( 'public', 'major_versions', '{}'::name[] );
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

/****************************************************************************/
-- What does the minor_versions() function look like?
SELECT has_function( 'public', 'minor_versions', ARRAY['text'] );
SELECT function_lang_is( 'minor_versions', 'sql' );
SELECT function_returns( 'minor_versions', 'setof int4' );
SELECT volatility_is( 'minor_versions', 'stable' );

-- Give it a shot.
SELECT is(
    ARRAY( SELECT * FROM minor_versions('8.3') ),
    ARRAY[ 0, 1, 2, 3, 4, 5, 6, 7 ],
    'Should get proper minor versions for "8.3"'
);

SELECT is(
    ARRAY( SELECT * FROM minor_versions('8.2') ),
    ARRAY[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ],
    'Should get proper minor versions for "8.2"'
);

SELECT is(
    ARRAY( SELECT * FROM minor_versions('8.4') ),
    ARRAY[ 0 ],
    'Should get proper minor versions for "8.4"'
);

/****************************************************************************/
-- What does the parse_fti_string() function look like?
SELECT has_function( 'public', 'parse_fti_string', ARRAY['text'] );
SELECT function_lang_is( 'parse_fti_string', 'plperl' );
SELECT function_returns( 'parse_fti_string', 'text' );
SELECT volatility_is( 'parse_fti_string', 'immutable' );

-- Give it a shot.
SELECT is(
    parse_fti_string('whatevz'),
    'whatevz:*',
    'parse_fti_string() should work with a single word'
);

SELECT is(
   parse_fti_string('this that'),
   'this:* & that:*',
   'parse_fti_string() should automatically AND terms'
);

SELECT is(
   parse_fti_string('this and that'),
   'this:* & that:*',
   'parse_fti_string() should recognize ANDs'
);

SELECT is(
   parse_fti_string('this or that'),
   'this:* | that:*',
   'parse_fti_string() should recognize ORs'
);

SELECT is(
   parse_fti_string('this not that'),
   'this:* ! that:*',
   'parse_fti_string() should recognize NOTs'
);

SELECT is(
    parse_fti_string('"whatevz, yo"'),
    '(whatevz:* & yo:*)',
    'parse_fti_string() should group quoted strings'
);

SELECT is(
    parse_fti_string('"whatevz, yo" or hey'),
    '(whatevz:* & yo:*) | hey:*',
    'parse_fti_string() should group quoted strings separate from other terms'
);

/****************************************************************************/
-- Finish up and go home.
SELECT * FROM finish();
ROLLBACK;
