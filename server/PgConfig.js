var FS = require('fs');
var Path = require('path');

module.exports = {
    getDbConfig : function(profile) {
        var dir = '../.config-db/';
        var env = process.env;
        var host = readFile(dir + 'db.host', env.DB_PORT_5432_TCP_ADDR || 'localhost');
        var port = readFile(dir + 'db.port', env.DB_PORT_5432_TCP_PORT || '5432');
        var user = readFile(dir + 'db.user', env.DB_ENV_POSTGRES_USER || 'postgres');
        var password = readFile(dir + 'db.pass', env.DB_ENV_POSTGRES_PASSWORD || 'postgres');
        var dbname = readFile(dir + 'db.name', env.DB_ENV_POSTGRES_DB || 'postgres');
        var result = {
            host : host,
            port : port,
            user : user,
            password : password,
            dbname : dbname
        };
        console.log('>>', result);
        return result;
    }
};

function readFile(name, defaultValue) {
    var file = Path.resolve(__dirname, name);
    var content = defaultValue;
    try {
        content = FS.readFileSync(file, 'UTF-8') || defaultValue;
    } catch (err) {
    }
    content = content || defaultValue;
    content = content.replace(/^[\s\r\n]*|[\s\r\n]$/gim, '');
    return content;
}
