BEGIN;
SELECT plan( 43 );
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
-- What does the get_upgrade_warnings() function look like?
SELECT has_function( 'public', 'get_upgrade_warnings', ARRAY['text', 'integer', 'integer'] );
SELECT function_lang_is( 'get_upgrade_warnings', 'plpgsql' );
SELECT function_returns( 'get_upgrade_warnings', 'setof record' );
SELECT volatility_is( 'get_upgrade_warnings', 'volatile' );

-- Give it a shot.
SELECT is( COUNT(*), 3::bigint, 'get_upgrade_warnings() should return rows' )
FROM get_upgrade_warnings('8.0', 2, 8);

SELECT is( COUNT(*), 0::bigint, 'get_upgrade_warnings() should return no rows for reversed minors' )
FROM get_upgrade_warnings('8.0', 8, 2);

SELECT is( COUNT(*), 0::bigint, 'get_upgrade_warnings() should return no rows for same minors' )
FROM get_upgrade_warnings('8.0', 8, 8);

PREPARE get_warnings AS SELECT version, warning FROM get_upgrade_warnings($1, $2, $3);
PREPARE exp_warnings AS SELECT $1 || '.' || $2 || '.' || minor::TEXT, upgrade_warning
    FROM   versions
    WHERE  super = $1::int
      AND  major = $2::int
      AND  minor > ( $3::int )
      AND  minor <= ( $4::int )
      AND  upgrade_warning <> ''
    ORDER BY super, major, minor;

SELECT results_eq(
    $$ EXECUTE get_warnings('8.0', 2, 8) $$,
    $$ EXECUTE exp_warnings(8, 0, 2, 8) $$,
    'get_upgrade_warnings() should return the proper rows for 8.0'
);

SELECT results_eq(
    $$ EXECUTE get_warnings('8.3', 0, 1) $$,
    $$ EXECUTE exp_warnings(8, 3, 0, 1) $$,
    'get_upgrade_warnings() should return the proper rows for 8.3'
);

SELECT results_eq(
    $$ EXECUTE get_warnings('8', 2, 8) $$,
    $$ EXECUTE exp_warnings(8, 0, 2, 8) $$,
    'get_upgrade_warnings() should return the proper rows for 8'
);

SELECT results_eq(
    $$ EXECUTE get_warnings('8', 8, 2) $$,
    $$ EXECUTE exp_warnings(8, 0, 8, 2) $$,
    'get_upgrade_warnings() should return the proper rows for reversed minors'
);

/****************************************************************************/
-- What does the get_fixes() function look like?
SELECT has_function( 'public', 'get_fixes', ARRAY['text', 'integer', 'integer', 'text'] );
SELECT function_lang_is( 'get_fixes', 'plpgsql' );
SELECT function_returns( 'get_fixes', 'setof record' );
SELECT volatility_is( 'get_fixes', 'volatile' );

-- Give it a shot.
SELECT is( COUNT(*), 15::bigint, 'get_fixes() should return rows' )
FROM get_fixes('8.0', 2, 3, '');

SELECT is( COUNT(*), 2::bigint, 'get_fixes() should return 2 rows with FT search' )
FROM get_fixes('8.0', 2, 3, 'pg_dump');

SELECT is( COUNT(*), 0::bigint, 'get_fixes() should return no rows for reversed minors' )
FROM get_fixes('8.0', 3, 2, '');

SELECT is( COUNT(*), 0::bigint, 'get_fixes() should return no rows for same minors' )
FROM get_fixes('8.0', 2, 2, '');

PREPARE have_fixes AS SELECT version, warning FROM get_fixes($1, $2, $3, $4);


/****************************************************************************/
-- Finish up and go home.
SELECT * FROM finish();
ROLLBACK;
