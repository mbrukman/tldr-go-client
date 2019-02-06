VERSION?=dev
COMMIT=$(shell git rev-parse HEAD | cut -c -8)

LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.Commit=${COMMIT}"
MODFLAGS=-mod=vendor

PLATFORMS:=darwin linux windows

all: dev

clean:
	rm -fr dist/
	rm -fr pages/
	rm -fr pages_*.go

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

dev: generate
	go build ${MODFLAGS} ${LDFLAGS} -o dist/tldr ./cmd/tldr

dist: generate $(PLATFORMS)

$(PLATFORMS):
	GOOS=$@ GOARCH=amd64 go build ${MODFLAGS} ${LDFLAGS} -o dist/tldr-$@-amd64 ./cmd/tldr

test:
	go test ${MODFLAGS} ./...

.PHONY: all clean setup generate dev dist darwin linux windows test
