var OsmService = require('./OsmService');
var PgConfig = require('../PgConfig');
module.exports = function() {
    var config = PgConfig.getDbConfig('osm');
    return new OsmService(config);
};

