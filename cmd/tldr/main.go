package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/tombell/tldr"
)

const helpText = `Simplified and community-driven man pages
Usage: tldr [command]
  -version
      Display version
`

var (
	version = flag.Bool("version", false, "")
)

func usage() {
	fmt.Fprintf(os.Stderr, helpText)
	os.Exit(2)
}

func main() {
	flag.Usage = usage
	flag.Parse()

	if *version {
		fmt.Fprintf(os.Stdout, "tldr %s (%s)\n", Version, Commit)
		os.Exit(0)
	}

	args := flag.Args()
	if len(args) == 0 {
		flag.Usage()
	}

	if err := tldr.Show(args[0]); err != nil {
		panic(err)
	}
}
