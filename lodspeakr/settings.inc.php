<?php

$conf['endpoint']['local'] = 'http://purl.org/twc/lodcloud/sparql';
$conf['home'] = '/var/www/lodspeakr/';
$conf['basedir'] = 'http://purl.org/twc/lodcloud/';
$conf['debug'] = false;

$conf['ns']['local']   = 'http://purl.org/twc/lodcloud';


$conf['mirror_external_uris'] = false;

// Cherry-picked components (see https://github.com/alangrafu/lodspeakr/wiki/Reuse-cherry-picked-components-from-other-repositories)

// Variables in  can be used to store user info.
// For examples, 'title' will be used in the header.
// (You can forget about all conventions and use your own as well)
$lodspk['title'] = 'LODSPeaKr';
?>
