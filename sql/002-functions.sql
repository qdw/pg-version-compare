SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

BEGIN;

CREATE FUNCTION get_fixes(
    major_version text,
    start_minor   text,
    end_minor     text,
    text_search   text,
    OUT version   text,
    OUT warning   text
) RETURNS SETOF record LANGUAGE plpgsql AS $$
DECLARE
    vmajor    INT;
    vsuper    INT;
    ts_string TEXT;
BEGIN
    vsuper := substring(major_version from $x$(\d+)\.\d+$x$)::INT;
    vmajor := substring(major_version from $x$\d+\.(\d+)$x$)::INT;
    ts_string := parse_fti_string(text_search);

    IF ts_string <> '' THEN
        RETURN QUERY
        SELECT major_version || '.' || minor::TEXT, fix_desc
        FROM   fixes
        WHERE  super = vsuper
          AND  major = vmajor
          AND  minor > ( start_minor::INT )
          AND  minor <= ( end_minor::INT )
          AND  fix_tsv @@ to_tsquery(ts_string)
        ORDER BY super, major, minor, fix_desc;      
    ELSE 
        RETURN QUERY
        SELECT major_version || '.' || minor::TEXT, fix_desc
        FROM   fixes
        WHERE  super = vsuper
          AND  major = vmajor
          AND  minor > ( start_minor::INT )
          AND  minor <= ( end_minor::INT )
        ORDER BY super, major, minor, fix_desc;
    END IF;
END;
$$;

CREATE FUNCTION get_upgrade_warnings(
    major_version text,
    start_minor   text,
    end_minor     text,
    OUT version   text,
    OUT warning   text
) RETURNS SETOF record LANGUAGE plpgsql AS $$
DECLARE
    vmajor INT;
    vsuper INT;
BEGIN
    vsuper := substring(major_version from $x$(\d+)\.\d+$x$)::INT;
    vmajor := substring(major_version from $x$\d+\.(\d+)$x$)::INT;
    RETURN QUERY
    SELECT major_version || '.' || minor::TEXT, upgrade_warning
    FROM   versions
    WHERE  super = vsuper
      AND  major = vmajor
      AND  minor > ( start_minor::INT )
      AND  minor <= ( end_minor::INT )
      AND  upgrade_warning <> ''
    ORDER BY super, major, minor;
END;
$$;

CREATE FUNCTION major_versions() RETURNS SETOF text LANGUAGE sql STABLE AS $$
    SELECT super::TEXT || '.' || major::TEXT
    FROM   versions
    GROUP BY super, major
    ORDER BY super, major;
$$;


CREATE FUNCTION minor_versions(
    major text
) RETURNS SETOF integer LANGUAGE sql STABLE STRICT AS $$
    SELECT minor
    FROM   versions
    WHERE  super = substring($1 from $x$(\d+)\.\d+$x$)::INT
    AND    major = substring($1 from $x$\d+\.(\d+)$x$)::INT
    ORDER BY minor;
$$;

CREATE FUNCTION parse_fti_string(
    expression text
) RETURNS text LANGUAGE plperl IMMUTABLE STRICT AS $_X$
    (my $exp = shift) =~ s/["']([^"']*?)["']/($1)/g;
    my $result;
    for (split /\s+/, $exp) {
        s/([^\w()&|!-])//g;
        if (/^and$/i) {
            $result .= " &" if defined $result and $result !~ /[|&]$/;
        } elsif (/^or$/i) {
            $result .= " |" if defined $result and $result !~ /[|&]$/;
        } elsif (/^not$/i) {
            $result .= " !" if defined $result and $result !~ /[|&!]$/;
        } else {
            if (!defined $result) {
                $result = $_;
            } elsif ( $result =~ /[(|&!]$/ ) {
                $result .= " " . $_;
            } else {
                $result .= " & " . $_;
            }
            $result =~ s/(\w*)([)]?)$/$1:*$2/;
        }
    }

    return $result;
$_X$;

-- '  -- SQL syntax highlighting fix (does not understand Perl)

COMMIT;
