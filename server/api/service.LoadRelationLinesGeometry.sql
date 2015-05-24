SELECT id, ST_AsGeoJson(ST_Transform(ST_Union(way),4326))::json AS geometry
FROM 
(
   SELECT L.id AS id, R.way AS way
   FROM (
        SELECT R.osm_id AS osm_id, R.way as way FROM planet_osm_line AS R
        UNION 
        SELECT R.osm_id AS osm_id, R.way as way FROM planet_osm_roads AS R
   ) AS R, (SELECT * FROM planet_osm_rels) AS L
   WHERE R.osm_id = ANY (L.parts) AND L.id IN (<%=ids.join(',')%>)
) AS T
GROUP BY id
