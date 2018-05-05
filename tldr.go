package tldr

import (
	"fmt"
	"os"
	"regexp"
	"strings"

	"github.com/fatih/color"
)

const argumentRegex = `{{|}}`

// Show render the TLDR page for the given command.
func Show(cmd string) error {
	bytes, err := GetAsset(fmt.Sprintf("%s.md", cmd))
	if err != nil {
		return fmt.Errorf("could not find page for %s", cmd)
	}

	formatted := format(string(bytes))

	fmt.Fprintf(os.Stdout, formatted)

	return nil
}

func format(page string) string {
	sep := "\n"
	lines := strings.Split(page, sep)

	prevline := ""
	formatted := []string{}

	for _, line := range lines {
		if len(prevline) > 0 && prevline[0] == '-' && len(line) == 0 {
			continue
		}

		prevline = line

		if len(line) > 0 {
			switch line[0] {
			case '#':
				line = strings.TrimSpace(line[1:])
			case '>':
				line = strings.TrimSpace(line[1:])
			case '-':
				line = "-" + color.GreenString(line[1:])
			case '`':
				line = strings.Trim(line, "`")

				r := regexp.MustCompile(argumentRegex)

				parts := r.Split(line, -1)

				for i := 0; i < len(parts); i += 2 {
					parts[i] = color.RedString(parts[i])
				}

				line = "  " + strings.Join(parts, "")
			}
		}

		formatted = append(formatted, line)
	}

	return strings.Join(formatted, sep)
}
