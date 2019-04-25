NAME = complete-shell
DOC = doc/$(NAME).swim
DOCS = $(shell echo doc/*)
MAN1 = man/man1
MANS = $(DOCS:doc/%.swim=$(MAN1)/%.1)

#------------------------------------------------------------------------------
default:

.PHONY: test
test:
	shellcheck .rc
	shellcheck .bashrc
	shellcheck ./bin/complete-shell
	@for file in $$(find . | grep -E '\.(bash|sh)$$' | grep -v '/\.git/'); do \
 	    echo "shellcheck $$file"; \
 	    shellcheck $$file; \
 	done

clean:
	make -C test $@

doc: $(MANS) ReadMe.pod

$(MAN1)/%.1: doc/%.swim
	swim --to=man $< > $@

ReadMe.pod: $(DOC)
	swim --to=pod --complete --wrap $< > $@
