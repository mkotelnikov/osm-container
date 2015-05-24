SELECT id, hstore_to_json_loose(tags::hstore) AS properties 
FROM planet_osm_rels
WHERE id IN (<%=ids.join(',')%>)
