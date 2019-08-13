function composer_install {

	if [ ! -f "composer.json" ]; then
		echo "No composer.json present, skipping composer install."
		return 0
	fi

	export COMPOSER_PROCESS_TIMEOUT=1200
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

function vendor_expose {
	# Now that composer has ran, we can test for ss4
	if [ ! -d "vendor/silverstripe/vendor-plugin" ]; then
		echo "SilverStripe 3 detected. Skipping module exposure."
		return 0
	fi

	echo "SilverStripe 4 detected. Running 'composer vendor-expose'."
	echo composer vendor-expose copy
	RETVAL="0"
	composer vendor-expose copy || RETVAL=$?

	if [ "$RETVAL" -gt "0" ]; then
		echo "[WARNING] 'composer vendor-expose' failed. Falling back to vendor-plugin-helper." >&2
		/tmp/vendor/bin/vendor-plugin-helper copy ./
	fi
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
