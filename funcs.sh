# We want to disable vendor-expose calls during composer install, as we run
# this manually later, but earlier releases of silverstripe/vendor-plugin
# have a broken 'none' mode implementation, so we fall back to 'copy' mode.
function disable_postinstall_vendor_expose {
	if [ ! -f "composer.lock" ]; then
		return 0
	fi

	# Default to 'copy' mode to avoid symlink generation
	export SS_VENDOR_METHOD="copy"

	safeversion="1.4.1"
	currentversion="$(cat composer.lock | jq -r '.packages[] | select(.name == "silverstripe/vendor-plugin") | .version')"

	# Too difficult to determine safety if the project uses an unstable version, emit warning
	if [ "`echo ${currentversion: -3}`" = "dev" ]; then
		echo "[WARNING] Please update silverstripe/vendor-plugin to ^1.4.1@stable to avoid triggering vendor-expose twice during deployment"
		return 0
	fi

	# Switch to 'none' mode if running a safe version of vendor-plugin
	if [ "$(printf '%s\n' "$safeversion" "$currentversion" | sort -V | head -n1)" = "$safeversion" ]; then
		echo "silverstripe/vendor-plugin $currentversion found, deferring vendor-expose"
		export SS_VENDOR_METHOD="none"
	else
		echo "[WARNING] Please update silverstripe/vendor-plugin to ^1.4.1@stable to avoid triggering vendor-expose twice during deployment"
	fi
}

# TODO: Allow scripts during composer install if explicit configuration is present
function composer_install {
	if [ ! -f "composer.json" ]; then
		echo "No composer.json present, skipping composer install."
		return 0
	fi

	export COMPOSER_PROCESS_TIMEOUT=1200

	echo "composer validate"
	composer validate || true

	echo "composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest"
	composer install \
		--no-progress \
		--prefer-dist \
		--no-dev \
		--ignore-platform-reqs \
		--optimize-autoloader \
		--no-interaction \
		--no-suggest
}

# Attempts to use vendor-plugin, falls back to legacy vendor-plugin-helper
# TODO: Remove fallback as it doesn't fully cover the behaviour of vendor-plugin
function composer_vendor_expose {
	echo "composer vendor-expose copy"
	RETVAL="0"
	composer vendor-expose copy || RETVAL=$?

	if [ "$RETVAL" -gt "0" ]; then
		echo "[WARNING] 'composer vendor-expose' failed. Falling back to vendor-plugin-helper. Please address this failure, as this fallback will be removed in a future update." >&2
		/root/.composer/vendor/bin/vendor-plugin-helper copy ./
	fi
}

function composer_build {
	echo "composer run-script cloud-build"
	composer run-script cloud-build
}

function set_node_version {
	. /root/.nvm/nvm.sh --no-use

	if [[ -f ".nvmrc" ]]; then
		echo "nvm use"
		nvm use
	else
		echo "No .nvmrc found; Defaulting to Node 10"
		nvm use 10
	fi
}

function node_build {
	if [[ -f "yarn.lock" ]]; then
		echo "yarn install --no-progress --non-interactive --frozen-lockfile"
		yarn install --no-progress --non-interactive --frozen-lockfile

		echo "yarn run cloud-build"
		yarn run cloud-build
	else
		echo "npm install"
		npm install

		echo "npm run cloud-build"
		npm run cloud-build
	fi

	echo "rm -rf node_modules/"
	rm -rf node_modules/
}

function package_source {
	echo "Packaging up source code"
	WORKING_DIR=${PWD##*/}
	cd ../
	mkdir -p site
	cp -rp ${WORKING_DIR}/. site
	rm -rf site/.git/
	tar -czf /payload-source-"$1".tgz site
	du -h /payload-source-"$1".tgz
}
