python_env_dir := $(PWD)/python-env
python_version := 3.6
python_site_packages := $(python_env_dir)/lib/python$(python_version)/site-packages
PYTHON := $(python_env_dir)/bin/python3

vim_doc_directories := $(shell find vim -name doc -type d)

.PHONY: all
all: zsh_generated_sources vim_doc_tags

.PHONY: vim_doc_tags
vim_doc_tags: $(vim_doc_directories:=/tags)

.PHONY: zsh_generated_sources
zsh_generated_sources: zsh/strager/strager_initialize_ls_colors zsh/strager/strager_initialize_menuselect

zsh/strager/strager_initialize_ls_colors: zsh/generate-strager-initialize-ls-colors.zsh
	$(<)

zsh/strager/strager_initialize_menuselect: zsh/generate-strager-initialize-menuselect.zsh
	$(<)

.PHONY: check
check: check-backup check-vim check-vim-lint check-zsh

.PHONY: check-backup
check-backup: $(PYTHON)
	cd backup && $(PYTHON) -m unittest discover -p '*.py'

.PHONY: check-vim
check-vim:
	vim/test.sh

.PHONY: check-vim-lint
check-vim-lint: $(python_env_dir)/bin/vint
	VINT="$$(cd $(python_env_dir) && pwd)/bin/vint" vim/lint.sh

.PHONY: check-zsh
check-zsh: $(python_site_packages)/pexpect
	PYTHON=$(PYTHON) zsh/test.zsh

.PHONY: format
format: format-python

.PHONY: format-python
format-python: $(python_env_dir)/bin/black
	$(python_env_dir)/bin/black --quiet -- backup/ zsh/

%/doc/tags: always_run
	vim \
		-c 'set verbosefile=/dev/stderr' \
		-c 'try | helptags $(dir $(@)) | catch | echomsg v:exception | cquit | endtry | qall!'

$(PYTHON):
	python3 -m venv -- $(python_env_dir)

$(python_env_dir)/bin/black: $(PYTHON)
	$(PYTHON) -m pip install black

$(python_env_dir)/bin/vint: $(PYTHON)
	$(PYTHON) -m pip install vim-vint

$(python_site_packages)/pexpect: $(PYTHON)
	$(PYTHON) -m pip install pexpect

.PHONY: always_run
always_run:
