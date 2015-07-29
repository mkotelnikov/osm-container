SELECT  T.* FROM 
(
    WITH R AS (
        SELECT R.id AS id, R.parts, R.tags::hstore, NULL as geometry 
        FROM planet_osm_rels AS R
        WHERE ((R.tags)::hstore)->'line' IN ('subway')
    )
    SELECT * FROM 
    (
        SELECT T.osm_id AS id, T.tags::hstore, T.way FROM planet_osm_point AS T, R WHERE T.osm_id = ANY (R.parts)
        UNION
        SELECT T.osm_id AS id, T.tags::hstore, T.way FROM planet_osm_line AS T, R WHERE T.osm_id = ANY (R.parts)
        UNION
        SELECT T.osm_id AS id, T.tags::hstore, T.way FROM planet_osm_roads AS T, R WHERE T.osm_id = ANY (R.parts)
        UNION
        SELECT T.osm_id AS id, T.tags::hstore, T.way FROM planet_osm_polygon AS T, R WHERE T.osm_id = ANY (R.parts)
        UNION 
        SELECT R.id AS id, R.tags::hstore, null AS way FROM R
    ) AS T
) AS T


SELECT R.id AS rel_id, T.* FROM 
(
    WITH R AS (
        SELECT R.id AS id, R.parts, 'Feature' AS type, hstore_to_json_loose(R.tags::hstore) AS properties, NULL as geometry 
        FROM planet_osm_rels AS R
        WHERE ((R.tags)::hstore)->'line' IN ('subway')
    )
    SELECT * FROM 
    (
        SELECT T.osm_id AS id, T.tags, T.way FROM planet_osm_point AS T, R WHERE T.osm_id = ANY (R.parts)
        UNION
        SELECT T.osm_id AS id, T.tags, T.way FROM planet_osm_line AS T, R WHERE T.osm_id = ANY (R.parts)
        UNION
        SELECT T.osm_id AS id, T.tags, T.way FROM planet_osm_roads AS T, R WHERE T.osm_id = ANY (R.parts)
        UNION
        SELECT T.osm_id AS id, T.tags, T.way FROM planet_osm_polygon AS T, R WHERE T.osm_id = ANY (R.parts)
        UNION 
        SELECT R.id AS id, R.tags, null AS way
    ) AS T
) AS T

--------------
SELECT T.* FROM 
(
    WITH R AS (
        SELECT R.id AS id, R.parts, 'Feature' AS type, hstore_to_json_loose(R.tags::hstore) AS properties, NULL as geometry 
        FROM planet_osm_rels AS R
        WHERE ((R.tags)::hstore)->'line' IN ('subway')
    )
    SELECT * FROM 
    (
        SELECT T.osm_id, T.tags, T.way FROM planet_osm_point AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts)  AND ((R.tags)::hstore)->'line' IN ('subway')
        UNION
        SELECT T.osm_id, T.tags, T.way FROM planet_osm_line AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts)  AND ((R.tags)::hstore)->'line' IN ('subway')
        UNION
        SELECT T.osm_id, T.tags, T.way FROM planet_osm_roads AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts) AND ((R.tags)::hstore)->'line' IN ('subway')
        UNION
        SELECT T.osm_id, T.tags, T.way FROM planet_osm_polygon AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts) AND ((R.tags)::hstore)->'line' IN ('subway')
    ) AS T

) AS T


SELECT osm_id AS id, 'Feature' AS type, hstore_to_json_loose(T.tags::hstore) AS properties, ST_AsGeoJson(ST_Transform(way,4326))::json as geometry
FROM
(
    SELECT T.osm_id, T.tags, T.way FROM planet_osm_point AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts)  AND ((R.tags)::hstore)->'line' IN ('subway')
    UNION
    SELECT T.osm_id, T.tags, T.way FROM planet_osm_line AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts)  AND ((R.tags)::hstore)->'line' IN ('subway')
    UNION
    SELECT T.osm_id, T.tags, T.way FROM planet_osm_roads AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts) AND ((R.tags)::hstore)->'line' IN ('subway')
    UNION
    SELECT T.osm_id, T.tags, T.way FROM planet_osm_polygon AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts) AND ((R.tags)::hstore)->'line' IN ('subway')
) AS T


SELECT osm_id AS id, 'Feature' AS type, hstore_to_json_loose(T.tags::hstore) AS properties, ST_AsGeoJson(ST_Transform(way,4326))::json as geometry
FROM
(SELECT id, tags, parts AS members FROM planet_osm_rels) AS R,
(
    SELECT T.osm_id, T.tags, T.way FROM planet_osm_point AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts::bigint[])
    UNION
    SELECT T.osm_id, T.tags, T.way FROM planet_osm_line AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts::bigint[])
    UNION
    SELECT T.osm_id, T.tags, T.way FROM planet_osm_roads AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts::bigint[])
    UNION
    SELECT T.osm_id, T.tags, T.way FROM planet_osm_polygon AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.parts::bigint[])
) AS T
WHERE T.osm_id = ANY (R.members)
    AND ((R.tags)::hstore)->'type' IN ('site')
--    AND T
    
    
SELECT osm_id AS id, 'Feature' AS type, hstore_to_json_loose(T.tags::hstore) AS properties, ST_AsGeoJson(ST_Transform(way,4326))::json as geometry
FROM
(SELECT id, tags, parts AS members FROM planet_osm_rels) AS R,
(
    SELECT R.id AS rel_id, T.osm_id, T.tags, T.way FROM planet_osm_point AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.members::bigint[])
    UNION
    SELECT R.id AS rel_id, T.osm_id, T.tags, T.way FROM planet_osm_line AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.members::bigint[])
    UNION
    SELECT R.id AS rel_id, T.osm_id, T.tags, T.way FROM planet_osm_roads AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.members::bigint[])
    UNION
    SELECT R.id AS rel_id, T.osm_id, T.tags, T.way FROM planet_osm_polygon AS T, planet_osm_rels AS R WHERE T.osm_id = ANY (R.members::bigint[])
) AS T
WHERE T.rel_id = R.id
    AND ((R.tags)::hstore)->'type' IN ('site')
--    AND T
        