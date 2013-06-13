
compile:
  "coffee -c -o lib src"

test:
	"mocha --compilers coffee:coffee-script"

.PHONY: test
