BINARY=tldr
GOARCH=amd64

VERSION?=dev
COMMIT=$(shell git rev-parse HEAD | cut -c -8)

LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.Commit=${COMMIT}"

PACKAGE=./cmd/tldr

all: dev

setup:
	go get -u github.com/tombell/lodge/cmd/lodge

tldr-pages:
	rm -fr pages
	mkdir -p pages
	curl -sSL https://github.com/tldr-pages/tldr/archive/master.tar.gz | tar -xz --strip-components=2 --directory pages tldr-master/pages/
	cp pages/common/* pages/linux/
	cp pages/common/* pages/osx/
	cp pages/common/* pages/sunos/
	cp pages/common/* pages/windows/

generate-data:
	lodge -output=./pages_linux.go   -pkg=tldr -prefix=pages/linux/   -build=linux   pages/common
	lodge -output=./pages_darwin.go  -pkg=tldr -prefix=pages/osx/     -build=darwin  pages/osx
	lodge -output=./pages_sunos.go   -pkg=tldr -prefix=pages/sunos/   -build=sunos   pages/sunos
	lodge -output=./pages_windows.go -pkg=tldr -prefix=pages/windows/ -build=windows pages/windows

clean:
	rm -fr dist/
	rm -fr pages/
	rm pages_*.go

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

.PHONY: all setup tldr-pages generate-data clean dev dist build linux darwin windows
