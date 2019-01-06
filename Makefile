python_env_dir := python-env
python_version := 3.6
python_site_packages := $(python_env_dir)/lib/python$(python_version)/site-packages
PYTHON := $(python_env_dir)/bin/python3

vim_doc_directories := $(shell find vim -name doc -type d)

.PHONY: all
all: vim_doc_tags

.PHONY: vim_doc_tags
vim_doc_tags: $(vim_doc_directories:=/tags)

.PHONY: check
check: check-zsh

.PHONY: check-zsh
check-zsh: $(python_site_packages)/pexpect
	PYTHON=$(PYTHON) zsh/test.zsh

.PHONY: format
format: format-python

.PHONY: format-python
format-python: $(python_env_dir)/bin/black
	$(python_env_dir)/bin/black --quiet -- zsh/

%/doc/tags: always_run
	vim \
		-c 'set verbosefile=/dev/stderr' \
		-c 'try | helptags $(dir $(@)) | catch | echomsg v:exception | cquit | endtry | qall!'

$(PYTHON):
	python3 -m venv -- $(python_env_dir)

$(python_env_dir)/bin/black: $(PYTHON)
	$(PYTHON) -m pip install black

$(python_site_packages)/pexpect: $(PYTHON)
	$(PYTHON) -m pip install pexpect

.PHONY: always_run
always_run:
