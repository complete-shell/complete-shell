export COMPLETE_SHELL_ROOT := $(shell cd .. && pwd)
export PATH := $(COMPLETE_SHELL_ROOT)/bin:$(PATH)

test ?= *.test

test:
	./tmux-test $(test)

clean:
	rm -fr _complete-shell
