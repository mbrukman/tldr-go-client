package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/tombell/tldr"
)

const helpText = `Simplified and community-driven man pages
Usage: tldr [command]
`

var (
	vrsn = flag.Bool("version", false, "")
)

func usage() {
	fmt.Fprintf(os.Stderr, helpText)
	os.Exit(2)
}

func main() {
	flag.Usage = usage
	flag.Parse()

	if *vrsn {
		fmt.Fprintf(os.Stdout, "tldr %s (%s)\n", version, commit)
		os.Exit(0)
	}

	args := flag.Args()
	if len(args) == 0 {
		flag.Usage()
	}

	if err := tldr.Show(args[0]); err != nil {
		fmt.Fprintf(os.Stderr, "err: %s\n", err)
		os.Exit(1)
	}
}
