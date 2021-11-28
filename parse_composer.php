#!/usr/bin/php
<?php

/**
 * This script collects private repositories from composer.json,
 * i.e. the ones with a "private": "true" property. It then proceeds to replace
 * these urls in composer.lock with a ssh gitlab.cwp.govt.nz equivalents and outputting
 * the result to the stdout.
 */

if (!file_exists($argv[1])) exit(1);
if (!file_exists($argv[2])) exit(1);

$fileJson = file_get_contents($argv[1]);
$fileLock = file_get_contents($argv[2]);

$json = json_decode($fileJson);
if (!$json) exit(2);

// If no repos, no need to process.
if (!isset($json->repositories)) {
	echo $fileLock;
	exit;
}

$privateRepos = array();
foreach ($json->repositories as $repo) {
	if (isset($repo->private) && $repo->private) {
		$privateRepos[] = $repo->url;
	}
}

// If no private repos, no need to process.
if (!count($privateRepos)) {
	echo $fileLock;
	exit;
}

// Replace all instances of private repos with gitlab.cwp.govt.nz SSH access.
foreach ($privateRepos as $private) {
	$replacement = preg_replace("#https://gitlab.[^/]*/#", 'ssh://git@gitlab.cwp.govt.nz:222/', $private);
	$fileLock = str_replace($private, $replacement, $fileLock);
}

echo $fileLock;
