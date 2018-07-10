all:
	docker build . -t silverstripe/platform-build:latest

push:
	docker push silverstripe/platform-build
