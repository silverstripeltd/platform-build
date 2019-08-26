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

function composer_build {
	echo "Running: Composer Production Build Task"
	composer run-script scp-build
}

function nvm_switch {
	if [[ -f ".nvmrc" ]]; then
		echo "Running: Apply NVM Configuration"
		. /root/.nvm/nvm.sh --no-use
		nvm use
	else
		echo "No .nvmrc found; Defaulting to Node 10"
	fi
}

function node_build {
	if [[ -f "yarn.lock" ]]; then
		echo "Running: Yarn Dependency Installation"
		yarn install --no-progress --non-interactive

		echo "Running: Yarn Production Build Task"
		yarn run scp-build
	else
		echo "Running: NPM Dependency Installation"
		npm install

		echo "Running: NPM Production Build Task"
		npm run scp-build
	fi

	echo "Running: Purge Node Modules"
	rm -rf node_modules/
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
