vim_doc_directories := $(shell find vim -name doc -type d)

.PHONY: all
all: vim_doc_tags

.PHONY: vim_doc_tags
vim_doc_tags: $(vim_doc_directories:=/tags)

%/doc/tags: always_run
	vim \
		-c 'set verbosefile=/dev/stderr' \
		-c 'try | helptags $(dir $(@)) | catch | echomsg v:exception | cquit | endtry | qall!'

.PHONY: always_run
always_run:
