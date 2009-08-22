BEGIN;
SELECT plan( 71 );
--SELECT * FROM no_plan();

/****************************************************************************/
-- Check for basic schema objects.
SELECT tables_are(     'public', ARRAY[ 'metadata', 'versions', 'fixes' ] );
SELECT views_are(      'public', '{}'::NAME[] );
SELECT sequences_are(  'public', '{}'::NAME[] );
SELECT rules_are(      'public', '{}'::NAME[] );
SELECT indexes_are(    'public', '{}'::NAME[] );
SELECT functions_are(  'public', ARRAY[
    'get_fixes',
    'get_upgrade_warnings',
    'major_versions',
    'minor_versions',
    'parse_fti_string'
] );

/****************************************************************************/
-- Validate metadata table.
SELECT has_pk( 'metadata' );

SELECT has_column( 'metadata', 'label' );
SELECT col_type_is( 'metadata', 'label', 'text' );
SELECT col_not_null( 'metadata', 'label' );
SELECT col_hasnt_default( 'metadata', 'label' );
SELECT col_is_pk( 'metadata', 'label' );

SELECT has_column( 'metadata', 'value' );
SELECT col_type_is( 'metadata', 'value', 'integer' );
SELECT col_not_null( 'metadata', 'value' );
SELECT col_has_default( 'metadata', 'value' );
SELECT col_default_is( 'metadata', 'value', 0 );

SELECT has_column( 'metadata', 'note' );
SELECT col_type_is( 'metadata', 'note', 'text' );
SELECT col_not_null( 'metadata', 'note' );
SELECT col_hasnt_default( 'metadata', 'note' );

-- Check that the schema is up-to-date.
SELECT is( value, 3, 'Schema should be up-to-date')
  FROM metadata WHERE label = 'schema_version';

/****************************************************************************/
-- Validate the versions table.
SELECT has_pk( 'versions' );

SELECT has_column( 'versions', 'super' );
SELECT col_type_is( 'versions', 'super', 'integer' );
SELECT col_not_null( 'versions', 'super' );
SELECT col_hasnt_default( 'versions', 'super' );

SELECT has_column( 'versions', 'major' );
SELECT col_type_is( 'versions', 'major', 'integer' );
SELECT col_not_null( 'versions', 'major' );
SELECT col_hasnt_default( 'versions', 'major' );

SELECT has_column( 'versions', 'minor' );
SELECT col_type_is( 'versions', 'minor', 'integer' );
SELECT col_not_null( 'versions', 'minor' );
SELECT col_hasnt_default( 'versions', 'minor' );

SELECT col_is_pk( 'versions', ARRAY['super', 'major', 'minor' ] );

SELECT has_column( 'versions', 'upgrade_warning' );
SELECT col_type_is( 'versions', 'upgrade_warning', 'text' );
SELECT col_not_null( 'versions', 'upgrade_warning' );
SELECT col_hasnt_default( 'versions', 'upgrade_warning' );

-- Validate the checks.
SELECT has_check( 'versions' );
SELECT col_has_check( 'versions', ARRAY[ 'major', 'minor', 'super' ] );

/****************************************************************************/
-- Validate the fixes table.
SELECT has_pk( 'fixes' );

SELECT has_column( 'fixes', 'super' );
SELECT col_type_is( 'fixes', 'super', 'integer' );
SELECT col_not_null( 'fixes', 'super' );
SELECT col_hasnt_default( 'fixes', 'super' );

SELECT has_column( 'fixes', 'major' );
SELECT col_type_is( 'fixes', 'major', 'integer' );
SELECT col_not_null( 'fixes', 'major' );
SELECT col_hasnt_default( 'fixes', 'major' );

SELECT has_column( 'fixes', 'minor' );
SELECT col_type_is( 'fixes', 'minor', 'integer' );
SELECT col_not_null( 'fixes', 'minor' );
SELECT col_hasnt_default( 'fixes', 'minor' );

SELECT has_column( 'fixes', 'fix_md5' );
SELECT col_type_is( 'fixes', 'fix_md5', 'text' );
SELECT col_not_null( 'fixes', 'fix_md5' );
SELECT col_hasnt_default( 'fixes', 'fix_md5' );

SELECT has_column( 'fixes', 'fix_desc' );
SELECT col_type_is( 'fixes', 'fix_desc', 'text' );
SELECT col_not_null( 'fixes', 'fix_desc' );
SELECT col_hasnt_default( 'fixes', 'fix_desc' );

SELECT has_column( 'fixes', 'fix_tsv' );
SELECT col_type_is( 'fixes', 'fix_tsv', 'tsvector' );
SELECT col_not_null( 'fixes', 'fix_tsv' );
SELECT col_hasnt_default( 'fixes', 'fix_tsv' );

SELECT col_is_pk( 'fixes', ARRAY['super', 'major', 'minor', 'fix_md5' ]);

-- Check the foreign key constraint.
SELECT has_fk( 'fixes' );
SELECT col_is_fk( 'fixes', ARRAY[ 'super', 'major', 'minor' ] );
SELECT fk_ok(
    'fixes',    ARRAY['super', 'major', 'minor' ],
    'versions', ARRAY['super', 'major', 'minor' ]
);

/****************************************************************************/
-- Finish up and go home.
SELECT * FROM finish();
ROLLBACK;
