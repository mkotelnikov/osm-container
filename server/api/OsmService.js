var _ = require('underscore');
var Mosaic = require('mosaic-commons');
var PgConnector = require('../PgConnector');

function readTemplate(file) {
    var FS = require('fs');
    var Path = require('path');
    var path = Path.join(__dirname, file);
    var str = FS.readFileSync(path, 'UTF-8');
    return _.template(str);
}

var SQL_TEMPLATE_FILES = {
    LoadRelationInfo : 'service.LoadRelationInfo.sql',
    LoadRelationGeometry : 'service.LoadRelationGeometry.sql',
    LoadRelationLinesGeometry : 'service.LoadRelationLinesGeometry.sql',
    LoadRelationMembers : 'service.LoadRelationMembers.sql',
    LoadRelationMembersWithInfo : 'service.LoadRelationMembersWithInfo.sql',
    LoadEntityRelations : 'service.LoadEntityRelations.sql',
    LoadEntityInfo : 'service.LoadEntityInfo.sql',
    SearchEntityInfo : 'service.SearchEntityInfo.sql',
    SearchEntityInfoInRelation : 'service.SearchEntityInfoInRelation.sql',
};

var OsmService = Mosaic.Class.extend({

    _sql : SQL_TEMPLATE_FILES,

    initialize : function(options) {
        this.setOptions(options);
        var dbUrl = this._getDbUrl();
        this.connector = new PgConnector({
            url : dbUrl,
            log : this._log.bind(this)
        });
        _.each(this._sql, function(file, key) {
            this._sql[key] = readTemplate(file);
        }, this);
    },

    // --------------------------------------------------------------------
    // Internal utility methods

    _getDbUrl : function() {
        var conf = this.options;
        var cred = conf.user;
        if (conf.password) {
            cred += ':' + conf.password;
        }
        if (cred && cred !== '') {
            cred += '@';
        }
        var dbUrl = 'postgres://' + cred + conf.host + ':' + conf.port + '/'
                + conf.dbname;
        return dbUrl;
    },

    // --------------------------------------------------------------------

    _log : function(msg) {
        console.log(msg);
    },

    _getIds : function(options) {
        var id = options.id || '';
        return id.split(',');
    },

    _execSql : function(sql, options) {
        return this.connector.exec({
            query : sql,
            offset : +options.offset || 0,
            limit : +options.limit || 100
        });
    },

    // --------------------------------------------------------------------

    /**
     * Returns information about the specified relation.
     */
    loadRelation : rest('/relation/:id', 'get', function(options) {
        var that = this;
        return Mosaic.P.then(function() {
            var ids = that._getIds(options);
            var sql = that._sql.LoadRelationInfo({
                ids : ids
            });
            return that._execSql(sql, options).then(function(results) {
                return ids.length > 1 ? results : results[0];
            });
        });
    }),

    /** Returns an aggregated geometry for the specified relation. */
    loadRelationLinesGeometry : rest('/relation/:id/lines', 'get', function(
            options) {
        var that = this;
        return Mosaic.P.then(function() {
            var ids = that._getIds(options);
            var sql = that._sql.LoadRelationLinesGeometry({
                ids : ids
            });
            return that._execSql(sql, options).then(function(results) {
                results = _.map(results, function(f) {
                    return _.extend({}, {
                        id : f.id
                    }, f.geometry);
                });
                return ids.length > 1 ? results : results[0];
            });
        });
    }),

    /** Returns an aggregated geometry for the specified relation. */
    loadRelationGeometry : rest('/relation/:id/geometry', 'get', function(
            options) {
        var that = this;
        return Mosaic.P.then(function() {
            var ids = that._getIds(options);
            var sql = that._sql.LoadRelationGeometry({
                ids : ids
            });
            return that._execSql(sql, options).then(function(results) {
                results = _.map(results, function(f) {
                    return _.extend({}, {
                        id : f.id
                    }, f.geometry);
                });
                return ids.length > 1 ? results : results[0];
            });
        });
    }),

    /** Returns full members information. */
    loadRelationMembersWithInfo : rest('/relation/full/:id', 'get', function(
            options) {
        var that = this;
        return Mosaic.P.then(function() {
            var ids = that._getIds(options);
            var sql = that._sql.LoadRelationMembersWithInfo({
                ids : ids
            });
            return that._execSql(sql, options);
        });
    }),

    /** Returns a list of all member identifiers. */
    loadRelationMembers : rest('/relation/:id/members', 'get',
            function(options) {
                var that = this;
                return Mosaic.P.then(function() {
                    var ids = that._getIds(options);
                    var sql = that._sql.LoadRelationMembers({
                        ids : ids
                    });
                    return that._execSql(sql, options).then(function(results) {
                        return ids.length > 1 ? results : results[0];
                    });
                });
            }),

    // ----------------------------------------------------------------------
    _getWhereStatement : function(propertiesCriteria) {
        var params = {}
        function serialize(val) {
            if (_.isArray(val)) {
                return '(' + _.map(val, serialize) + ')';
            } else {
                if (_.isString(val)) {
                    val = "'" + val + "'";
                } else {
                    val = JSON.stringify(val);
                }
                val = val.replace(/\*/gim, '%');
                return val;
            }
        }
        function getType(val) {
            var numeric = !_.find(val, function(v) {
                return !_.isNumber(v);
            });
            return numeric ? 'numeric' : undefined;
        }
        _.each(propertiesCriteria, function(val, key) {
            if (val === null) {
                params[key] = {
                    operator : 'IS NOT',
                    value : 'NULL'
                };
            } else if (_.isArray(val)) {
                params[key] = {
                    value : serialize(val),
                    operator : 'IN',
                    type : getType(val)
                }
            } else if (_.isObject(val)) {
                params[key] = val;
            } else if (_.isString(val)) {
                params[key] = {
                    value : serialize(val),
                    operator : 'ILIKE'
                };
            } else if (_.isNumber(val)) {
                params[key] = {
                    value : serialize(val),
                    operator : '=',
                    type : 'numeric'
                };
            } else {
                params[key] = {
                    value : serialize(val),
                    operator : '='
                };
            }
        });

        var where = '';
        where += _.map(params, function(o, k) {
            var key = "(R.properties->'" + k + "')";
            if (o.type) {
                key += "::" + o.type;
            }
            return "(" + key + ' ' + o.operator + " " + o.value + ")"
        }).join(' AND ');
        return where;
    },

    /**
     * Returns information about the specified entity (id, properties +
     * geometry).
     */
    searchEntityInfo : rest('/search', 'get', function(options) {
        var that = this;
        return Mosaic.P.then(function() {
            var where = that._getSearchWhereStatement(options);
            if (where) {
                where = 'WHERE (' + where + ')';
            }
            var sql = that._sql.SearchEntityInfo({
                where : where
            });
            // console.log('SEARCH SQL: ', sql);
            return that._execSql(sql, options);
        });
    }),

    /**
     * Returns information about the specified entity (id, properties +
     * geometry).
     */
    searchEntityInfoInRelation : rest('/relation/:id/search', 'get', function(
            options) {
        var that = this;
        return Mosaic.P.then(function() {
            var where = that._getSearchWhereStatement(options);
            if (where) {
                where = ' AND (' + where + ')';
            }
            var sql = that._sql.SearchEntityInfoInRelation({
                where : where,
                ids : that._getIds(options)
            });
            // console.log('RELATION SEARCH SQL: ', sql);
            return that._execSql(sql, options);
        });
    }),

    _getSearchWhereStatement : function(options) {
        var where = options.where;
        if (!where) {
            var propertiesCriteria;
            try {
                propertiesCriteria = JSON.parse(options.properties);
            } catch (err) {
                return [];
            }
            where = that //
            ._getWhereStatement(propertiesCriteria);
        }
        return where;
    },

    /**
     * Returns information about the specified entity (id, properties +
     * geometry).
     */
    loadEntityInfo : rest('/entity/:id', 'get', function(options) {
        var that = this;
        return Mosaic.P.then(function() {
            var ids = that._getIds(options);
            var sql = that._sql.LoadEntityInfo({
                ids : ids
            });
            return that._execSql(sql, options).then(function(results) {
                return ids.length > 1 ? results : results[0];
            });
        });
    }),

    /**
     * Returns all relations associated with the specified entity.
     */
    loadEntityRelations : rest('/entity/:id/relations', 'get',
            function(options) {
                var that = this;
                return Mosaic.P.then(function() {
                    var sql = that._sql.LoadEntityRelations({
                        ids : that._getIds(options)
                    });
                    return that._execSql(sql, options);
                });
            }),

});
module.exports = OsmService;

/**
 * This utility function "annotates" the specified object methods by the
 * corresponding REST paths and HTTP methods.
 */
function rest(path, http, method) {
    method.http = http;
    method.path = path;
    return method;
}
