function composer_install {

	if [ ! -f "composer.json" ]; then
		echo "No composer.json present, skipping composer install."
		return 0
	fi

	export COMPOSER_PROCESS_TIMEOUT=1200
	export SS_VENDOR_METHOD="copy"
	echo composer validate
    composer validate || true

    echo composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
    composer install \
        --no-progress \
        --prefer-dist \
        --no-dev \
        --ignore-platform-reqs \
        --optimize-autoloader \
        --no-interaction \
        --no-suggest
}

function package_source {
	echo Packaging up source code
	WORKING_DIR=${PWD##*/}
	cd ../
	mkdir -p site
	cp -rp ${WORKING_DIR}/. site
	rm -rf site/.git/
	tar -czf /payload-source-"$1".tgz site
	du -h /payload-source-"$1".tgz
}
