/*
 *
 * Folder to tarball and upload with SFTP
 * npm run upload <host> <user>
 * npm run upload <host> <user> <remoteDir>
 * remoteDir defaults to `/root`
 *
 * extract on server with
 * tar xvf inits.tgz -C inits
 *
 * Authentication is done by searching for a `ssh-pageant` and getting it's SSH_AUTH_SOCK,
 * also password or hardcoded keyfile possible
 */
const fs = require('fs');
const path = require('path');
const {packer} = require('./packer.js');

const uploader = (host, username, remote_dir, agent, port = 22) => {
    packer((file) => {
        let Client = require('ssh2-sftp-client');
        let sftp = new Client();

        let remote = remote_dir + '/' + file;

        console.log('Start uploading ' + path.resolve(__dirname, file) + ' to ' + host + ':' + port + '' + remote);
        sftp.connect({
            host,
            port,
            username,
            agent
            //password: '******'
        }).then(() => {
            let data = fs.createReadStream(path.resolve(__dirname, file));
            return sftp.put(data, remote, {});
        }).then(data => {
            //console.log(data);
            console.log('✓ uploaded file ' + file);
            sftp.end();
        }).catch(err => {
            console.error('X upload error', err);
            sftp.end();
        });
    });
};

console.log('Start Uploader, now find ssh_auth_sock');
const {exec} = require('child_process');
//exec('ssh-pageant | grep -P -o -e "SSH_AUTH_SOCK.*\';"', (err, stdout, stderr) => {
exec('ssh-pageant', (err, stdout, stderr) => {
    if(err) {
        console.error('Could not execute ssh-pageant');
        console.error(err);
        return;
    }
    if(stderr) {
        console.error('stderr', stderr);
        return;
    }

    // todo: check why grep in one line didn't worked
    exec('echo "' + stdout + '" | grep -P -o -e "SSH_AUTH_SOCK.*\';"', (err, stdout, stderr) => {
        let ssh_auth_sock = stdout.substr(0, stdout.indexOf('\';')).replace(/"SSH_AUTH_SOCK='/i, '').replace(/';/i, '');

        if(!process.argv[2] || !process.argv[3]) {
            console.error(
                (!process.argv[2] ? 'Missing Target `Host`' : '') +
                (!process.argv[2] && !process.argv[3] ? ', ' : '') +
                (!process.argv[3] ? 'Missing Target `User`' : '') +
                ': npm run upload <host> <user>');
            return;
        }

        uploader(process.argv[2], process.argv[3], process.argv[4] || '/root', ssh_auth_sock);
    });
});
