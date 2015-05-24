drop table if exists objects cascade;
create table objects(
    id SERIAL primary key,
    type varchar(255),
    properties json,
    geometry geometry, 
    check (st_srid(geometry) = 4326)
);

create or replace view objects_webmercator as 
select 
    objects.id,
    objects.type,
    objects.properties,
    objects.geometry,
    st_transform(objects.geometry, 3857) as the_geom_webmercator
from objects;
create index on objects(type);

/* -------------------------------------------------------------------------- */

/* * /
-- http://stackoverflow.com/questions/18404055/index-for-finding-an-element-in-a-json-array
create or replace function json_val_arr(j json) returns text[] as
$$
select array_agg(elem) from json_array_elements(j) as x(elem)
$$
  language sql immutable;
-- Index on categories
create index objects_categories_gin_idx on objects using gin(json_val_arr(categories));

-- Example of queries using this index
-- select * from objects where  '{"\"Entreprise\""}'::text[] <@ (json_val_arr((properties->'categories')));
-- */

/* -------------------------------------------------------------------------- */

drop function if exists convert_to_objects(t varchar(255), s varchar(255), n varchar(255));
create function convert_to_objects(t varchar(255), s varchar(255), n varchar(255))
returns integer as $$
begin
  execute 'insert into objects(type,properties,geometry) ' || 
    'select ' ||
      '''' || t || ''' as type, ' ||
      'row_to_json(t0) as properties, ' || 
      'st_transform(t1.geom, 4326) as geometry ' ||
      'from ( select '
      || array_to_string(array(select 'o' || '.' || c.column_name
        from information_schema.columns As c
            where table_schema = s and table_name = n 
            and  c.column_name NOT IN('geom','the_geom_webmercator')
    ), ',') || ' from ' || s || '.' || n || ' As o) as t0 join '
    || s || '.' || n || ' as t1 using (gid)';
  return 1;
end
$$ LANGUAGE plpgsql;

/* -------------------------------------------------------------------------- */

drop function if exists json_object_set_key(
    "json" json,
    "key_to_set"    TEXT,
    "value_to_set"  anyelement);
CREATE OR REPLACE FUNCTION "json_object_set_key"(
  "json"          json,
  "key_to_set"    TEXT,
  "value_to_set"  anyelement
)
  RETURNS json
  LANGUAGE sql
  IMMUTABLE
  STRICT
AS $function$
SELECT COALESCE(
  (SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')
     FROM (SELECT *
             FROM json_each("json")
            WHERE "key" <> "key_to_set"
            UNION ALL
           SELECT "key_to_set", to_json("value_to_set")) AS "fields"),
  '{}'
)::json
$function$;


/* -------------------------------------------------------------------------- */

drop function if exists json_object_set_keys(
    "json"          json,
    "keys_to_set"   TEXT[],
    "values_to_set" anyarray);
CREATE OR REPLACE FUNCTION "json_object_set_keys"(
    "json"          json,
    "keys_to_set"   TEXT[],
    "values_to_set" anyarray
)
  RETURNS json
  LANGUAGE sql
  IMMUTABLE
  STRICT
AS $function$
SELECT COALESCE(
  (SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')
     FROM (SELECT *
             FROM json_each("json")
            WHERE "key" <> ALL ("keys_to_set")
            UNION ALL
           SELECT DISTINCT ON ("keys_to_set"["index"])
                  "keys_to_set"["index"],
                  CASE
                    WHEN "values_to_set"["index"] IS NULL THEN 'null'
                    ELSE to_json("values_to_set"["index"])
                  END
             FROM generate_subscripts("keys_to_set", 1) AS "keys"("index")
             JOIN generate_subscripts("values_to_set", 1) AS "values"("index")
            USING ("index")) AS "fields"),
  '{}'
)::json
$function$;

/* -------------------------------------------------------------------------- */

drop function if exists json_object_remove_key(
    "json"          json,
    "key_to_remove"    TEXT);
CREATE OR REPLACE FUNCTION "json_object_remove_key"(
  "json"          json,
  "key_to_remove"    TEXT
)
  RETURNS json
  LANGUAGE sql
  IMMUTABLE
  STRICT
AS $function$
SELECT COALESCE(
  (SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')
     FROM (SELECT *
             FROM json_each("json")
            WHERE "key" <> "key_to_remove"
    ) AS "fields"),
  '{}'
)::json
$function$;


/* -------------------------------------------------------------------------- */

drop function if exists json_object_rename_key(
  "json"       json,
  "old_key"    TEXT,
  "new_key"    TEXT);
CREATE OR REPLACE FUNCTION "json_object_rename_key"(
  "json"       json,
  "old_key"    TEXT,
  "new_key"    TEXT
)
  RETURNS json
  LANGUAGE sql
  IMMUTABLE
  STRICT
AS $function$
SELECT COALESCE(
  (SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')
     FROM (SELECT * FROM json_each("json") WHERE "key" <> "old_key"
            UNION ALL
            SELECT "new_key", "value" FROM json_each("json")
            WHERE "key" = "old_key") AS "fields"),
  '{}'
)::json
$function$;

