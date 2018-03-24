BINARY=tldr
GOARCH=amd64

VERSION?=dev
COMMIT=$(shell git rev-parse HEAD | cut -c -8)

LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.Commit=${COMMIT}"

PACKAGE=./cmd/tldr

all: dev

tldr-pages:
	rm -fr pages
	mkdir -p pages
	curl -sSL https://github.com/tldr-pages/tldr/archive/master.tar.gz | tar -xz --strip-components=2 --directory pages tldr-master/pages/

clean:
	rm -fr dist/

dev: build

dist: linux darwin windows

build:
	go build ${LDFLAGS} -o dist/${BINARY} ${PACKAGE}

linux:
	GOOS=linux GOARCH=${GOARCH} go build ${LDFLAGS} -o dist/${BINARY}-linux-${GOARCH} ${PACKAGE}

darwin:
	GOOS=darwin GOARCH=${GOARCH} go build ${LDFLAGS} -o dist/${BINARY}-darwin-${GOARCH} ${PACKAGE}

windows:
	GOOS=windows GOARCH=${GOARCH} go build ${LDFLAGS} -o dist/${BINARY}-windows-${GOARCH} ${PACKAGE}

.PHONY: all tldr-pages clean dev dist build linux darwin windows
