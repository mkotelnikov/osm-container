SELECT osm_id AS id, 'Feature' AS type, hstore_to_json_loose(tags::hstore) AS properties, ST_AsGeoJson(ST_Transform(way,4326))::json
FROM planet_osm_point
WHERE (tags::hstore)->'highway' in ('bus_stop');