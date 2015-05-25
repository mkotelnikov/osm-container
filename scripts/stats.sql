/* STATS FOR NODE TAGS */
DROP TABLE IF EXISTS tag_stats_nodes;

CREATE TABLE tag_stats_nodes AS 
SELECT keys AS key, count(keys) AS count FROM (
SELECT unnest(akeys(tags::hstore)) AS keys
FROM planet_osm_nodes
) AS T
GROUP BY keys;
-- */

/* STATS FOR NODE WAYS */
DROP TABLE IF EXISTS tag_stats_ways;

CREATE TABLE tag_stats_ways AS 
SELECT keys AS key, count(keys) AS count FROM (
SELECT unnest(akeys(tags::hstore)) AS keys
FROM planet_osm_ways
) AS T
GROUP BY keys;
-- */

/* STATS FOR NODE RELATIONS */
DROP TABLE IF EXISTS tag_stats_rels;

CREATE TABLE tag_stats_rels AS 
SELECT keys AS key, count(keys) AS count FROM (
SELECT unnest(akeys(tags::hstore)) AS keys
FROM planet_osm_rels
) AS T
GROUP BY keys;
-- */

/** Select all stats */
SELECT key, sum(count) FROM (
    SELECT * FROM tag_stats_nodes
UNION
    SELECT * FROM tag_stats_ways
UNION
    SELECT * FROM tag_stats_rels
) AS T
GROUP BY key;
-- */

/** Create full stats table */
DROP TABLE IF EXISTS tag_stats;
CREATE TABLE tag_stats AS
SELECT
    K.key AS key,
    K.count AS total,
    N.count AS nodes,
    W.count AS ways,
    R.count AS rels
FROM (
SELECT key, sum(count) AS count FROM (
    SELECT * FROM tag_stats_nodes AS N
UNION
    SELECT * FROM tag_stats_ways AS W
UNION
    SELECT * FROM tag_stats_rels AS R
) AS T
GROUP BY key
ORDER BY count desc
) AS K
LEFT JOIN tag_stats_nodes AS N ON N.key = K.key
LEFT JOIN tag_stats_ways AS W ON W.key = K.key
LEFT JOIN tag_stats_rels AS R ON R.key = K.key;

UPDATE tag_stats SET nodes=0 WHERE nodes IS NULL;
UPDATE tag_stats SET ways=0 WHERE ways IS NULL;
UPDATE tag_stats SET rels=0 WHERE rels IS NULL;
-- */

