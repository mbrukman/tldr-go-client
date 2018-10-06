VERSION?=dev
COMMIT=$(shell git rev-parse HEAD | cut -c -8)

LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.Commit=${COMMIT}"
MODFLAGS=-mod=vendor

BINARY=tldr
PACKAGE=./cmd/tldr

all: dev

setup:
	go get -u github.com/tombell/lodge/cmd/lodge

pages:
	mkdir -p pages
	curl -sSL https://github.com/tldr-pages/tldr/archive/master.tar.gz | tar -xz --strip-components=2 --directory pages tldr-master/pages/
	cp pages/common/* pages/linux/
	cp pages/common/* pages/osx/
	cp pages/common/* pages/windows/

generate: pages
	lodge -gzip -pkg=tldr -output=./pages_linux.go   -prefix=pages/linux/   -build=linux   pages/common
	lodge -gzip -pkg=tldr -output=./pages_darwin.go  -prefix=pages/osx/     -build=darwin  pages/osx
	lodge -gzip -pkg=tldr -output=./pages_windows.go -prefix=pages/windows/ -build=windows pages/windows

clean:
	rm -fr dist/
	rm -fr pages/
	rm -fr pages_*.go

dev: generate
	go build ${MODFLAGS} ${LDFLAGS} -o dist/${BINARY} ${PACKAGE}

dist: generate darwin linux windows

darwin:
	GOOS=darwin GOARCH=amd64 go build ${LDFLAGS} -o dist/${BINARY}-darwin-amd64 ${PACKAGE}

linux:
	GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o dist/${BINARY}-linux-amd64 ${PACKAGE}

windows:
	GOOS=windows GOARCH=amd64 go build ${LDFLAGS} -o dist/${BINARY}-windows-amd64 ${PACKAGE}

test:
	go test ${MODFLAGS} ./...

.PHONY: all setup generate clean dev dist darwin linux windows test
