# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

IMAGE = elastifileio/provisioner

VERSION :=
TAG := $(shell git describe --abbrev=0 --tags HEAD 2>/dev/null)
COMMIT := $(shell git rev-parse HEAD)
ifeq ($(TAG),)
    VERSION := latest
else
    ifeq ($(COMMIT), $(shell git rev-list -n1 $(TAG)))
        VERSION := $(TAG)
    else
        VERSION := latest
    endif
endif

all build:
	GOOS=linux go install -v
	GOOS=linux go build
.PHONY: all build

container: build quick-container
.PHONY: container

quick-container:
	cp elastifile-provisioner deploy/docker/elastifile-provisioner
	docker build -t $(IMAGE):$(VERSION) deploy/docker
.PHONY: quick-container

push: container
	docker push $(IMAGE):$(VERSION)
.PHONY: push

test-integration: verify-gofmt
	go test `go list ./... | grep -v 'vendor\|e2e'`
.PHONY: test-integration

test-e2e: verify-gofmt
	go test ./e2e -v --kubeconfig=$(HOME)/.kube/config
.PHONY: test-e2e

verify-gofmt:
	(gofmt -s -w -l `find . -type f -name "*.go" | grep -v vendor`) || exit 1
.PHONY: verify-gofmt

clean:
	rm -f elastifile-provisioner
	rm -f deploy/docker/elastifile-provisioner
.PHONY: clean
