test:
	swift test --enable-test-discovery --parallel

docker-sh: docker-build
	docker run -it swift-directory-kit-image /bin/bash

docker-run: docker-build
	docker run --rm swift-directory-kit-image

docker-build:
	docker build -t swift-directory-kit-image .

