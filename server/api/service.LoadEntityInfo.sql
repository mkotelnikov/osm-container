SELECT osm_id AS id, 'Feature' AS type, hstore_to_json_loose(tags::hstore) AS properties, ST_AsGeoJson(ST_Transform(way,4326))::json as geometry
FROM
(
    SELECT osm_id, tags, way FROM planet_osm_point
    UNION
    SELECT osm_id, tags, way FROM planet_osm_line
    UNION
    SELECT osm_id, tags, way FROM planet_osm_roads
    UNION
    SELECT osm_id, tags, way FROM planet_osm_polygon
) AS T
WHERE osm_id IN (<%=ids.join(',')%>)