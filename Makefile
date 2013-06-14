compile:
	coffee -c -o lib src
	node ./lib/parser/constraint/grammar.js

test:
	mocha --compilers coffee:coffee-script

.PHONY: test
