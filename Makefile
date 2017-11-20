GIT_COMMIT ?= $(shell git rev-parse HEAD)

all:
	docker build . -t quay.io/mozmar/fluentd:${GIT_COMMIT}
	docker push quay.io/mozmar/fluentd:${GIT_COMMIT}
