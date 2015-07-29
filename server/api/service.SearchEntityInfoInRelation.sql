SELECT N.id AS id, 'Feature' AS type, hstore_to_json(N.properties) AS properties, ST_AsGeoJson(N.geometry)::json as geometry FROM (
	SELECT osm_id AS id, tags::hstore AS properties, ST_Transform(way,4326) as geometry
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
) AS N,
planet_osm_rels AS R
WHERE N.id = ANY (R.parts) AND R.id IN (<%=ids.join(',')%>) 
<%=where%>