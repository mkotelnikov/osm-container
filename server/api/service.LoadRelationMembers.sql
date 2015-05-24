SELECT id, parts AS members
FROM planet_osm_rels
WHERE id IN (<%=ids.join(',')%>)