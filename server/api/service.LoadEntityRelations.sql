SELECT rel_id AS id, hstore_to_json_loose(tags::hstore) AS properties, parts AS members
FROM 
(
   SELECT L.id AS rel_id, L.parts AS parts, L.tags AS tags
   FROM (
        SELECT R.osm_id AS osm_id FROM planet_osm_point AS R
        UNION 
        SELECT R.osm_id AS osm_id FROM planet_osm_line AS R
        UNION 
        SELECT R.osm_id AS osm_id FROM planet_osm_roads AS R
        UNION 
        SELECT R.osm_id AS osm_id FROM planet_osm_polygon AS R
--        UNION
--        SELECT R.id as osm_id FROM planet_osm_nodes AS R
--        UNION
--        SELECT R.id as osm_id FROM planet_osm_ways AS R
   ) AS R, (SELECT * FROM planet_osm_rels) AS L
   WHERE R.osm_id = ANY (L.parts) and R.osm_id IN (<%=ids.join(',')%>)
) AS T