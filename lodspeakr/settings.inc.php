<?php

$conf['endpoint']['local'] = 'http://datafaqs.tw.rpi.edu/sparql';
$conf['home'] = '/var/www/lodspeakr/';
$conf['basedir'] = 'http://datafaqs.tw.rpi.edu/';
$conf['debug'] = false;

$conf['ns']['local']   = 'http://datafaqs.tw.rpi.edu';


$conf['mirror_external_uris'] = false;

// Cherry-picked components (see https://github.com/alangrafu/lodspeakr/wiki/Reuse-cherry-picked-components-from-other-repositories)

// Variables in  can be used to store user info.
// For examples, 'title' will be used in the header.
// (You can forget about all conventions and use your own as well)
$lodspk['title'] = 'LODSPeaKr';
?>
