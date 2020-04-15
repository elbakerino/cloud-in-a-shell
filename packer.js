/*
 *
 * Folder to tarball
 *
 */
const fs = require('fs');
const path = require('path');

const scanner = function(dir, done, exclude = []) {
    let results = [];
    fs.readdir(dir, (err, list) => {
        if(err) return done(err);

        let pending = list.length;
        if(!pending) return done(null, results);

        list.forEach(function(file) {
            file = path.resolve(dir, file);
            fs.stat(file, function(err, stat) {
                if(stat && stat.isDirectory()) {
                    if(exclude.includes(file)) {
                        pending--;
                        if(!--pending) done(null, results);
                        return;
                    }
                    scanner(file, function(err, res) {
                        results = results.concat(res);
                        if(!--pending) done(null, results);
                    }, exclude);
                } else {
                    results.push(file);
                    if(!--pending) done(null, results);
                }
            });
        });
    });
};

const packDir = __dirname;
const packer = (done) => {
    console.log('Scanning Files and creating tarball...')
    scanner(packDir, (err, result) => {
        if(err) {
            console.error(err);
            return;
        }

        const tar = require('tar');
        const file = 'inits.tgz';
        const files = [];
        result.forEach(file => {
            // make clean relative file
            files.push(file.replace(new RegExp(__dirname.replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1"), 'g'), '').substr(1));
        });

        tar.c({gzip: true, file,}, files).then(() => {
            const stats = fs.statSync(file);
            let fileSizeInMegabytes = stats['size'] / 1000000.0;

            console.log('✓ ' + file + ' [' + fileSizeInMegabytes.toFixed(2) + 'mb] created .. ');
            done(file);
        });
    }, [
        path.resolve(__dirname, '.git'),
        path.resolve(__dirname, '.idea'),
        path.resolve(__dirname, '_dev'),
        path.resolve(__dirname, 'node_modules'),
    ]);
};

if(process.argv[2] === '--pack') {
    packer(() => {
    });
}

exports.packer = packer;
