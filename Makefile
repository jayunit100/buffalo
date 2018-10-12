TAGS ?= "sqlite"
GO_BIN ?= go

install: deps
	packr
	$(GO_BIN) install -tags ${TAGS} -v ./buffalo

deps:
	$(GO_BIN) get github.com/gobuffalo/release
	$(GO_BIN) get github.com/gobuffalo/packr/packr
	$(GO_BIN) get -tags ${TAGS} -t ./...
ifeq ($(GO111MODULE),on)
	$(GO_BIN) mod tidy
endif

build:
	packr
	$(GO_BIN) build -v .

test:
	packr
	$(GO_BIN) test -tags ${TAGS} ./...

lint:
	gometalinter --vendor ./... --deadline=30s --skip=internal --disable=goimports --enable=gofmt

ci-deps:
	$(GO_BIN) get -u github.com/alecthomas/gometalinter
	gometalinter --install
	$(GO_BIN) get github.com/gobuffalo/packr/packr
	$(GO_BIN) get -tags "sqlite integration_test" -t -u -v ./...

update:
	$(GO_BIN) get -u -tags ${TAGS}
ifeq ($(GO111MODULE),on)
	$(GO_BIN) mod tidy
endif
	packr
	make test
	make install
ifeq ($(GO111MODULE),on)
	$(GO_BIN) mod tidy
endif

release-test:
	make test

release:
	release -y -f ./runtime/version.go
