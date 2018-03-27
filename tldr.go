package tldr

import (
	"fmt"
	"os"
)

// Show render the TLDR page for the given command.
func Show(cmd string) error {
	bytes, ok := Assets[fmt.Sprintf("%s.md", cmd)]
	if !ok {
		return fmt.Errorf("could not find page for %s", cmd)
	}

	fmt.Fprintf(os.Stdout, string(bytes))

	return nil
}
