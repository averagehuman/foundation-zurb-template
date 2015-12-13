
SHELL := /bin/bash
VIRTUAL_ENV ?= $(abspath .pyenv)
VENV := $(VIRTUAL_ENV)
PYTHON := python3
PIP := $(VENV)/bin/pip
NODE := $(VENV)/bin/node
NODE_VERSION := 4.2.3
NPM := $(VENV)/bin/npm
BOWER := $(abspath node_modules/.bin/bower)
GULP := $(abspath node_modules/.bin/gulp)
DIST_ROOT := $(abspath dist)
DEBUG ?= 0

export VIRTUAL_ENV

.PHONY: venv develop serve publish clean nuke

venv:
	@if [ ! -e $(VENV) ]; then virtualenv -v -p $(PYTHON) $(VENV); fi
	@$(PIP) install -U pip
	@$(PIP) install -r requirements.txt

nodejs:
	@if [ ! -e $(NODE) ]; then \
		echo "Installing nodejs. This may take a few minutes." && $(VENV)/bin/nodeenv -v -p --node=$(NODE_VERSION); \
	fi

install: venv nodejs
	@source $(VENV)/bin/activate && $(NPM) install && $(BOWER) install

start:
	@source $(VENV)/bin/activate && $(NPM) start

build:
	@source $(VENV)/bin/activate && $(GULP) build --production

publish: build
	@s3cmd sync $(DIST_ROOT)/ s3://$(S3_BUCKET) --acl-public --delete-removed --guess-mime-type

clean:
	@rm -rf $(DIST_ROOT)

nuke: clean
	@rm -rf $(VIRTUAL_ENV)
	@rm -rf ./node_modules
	@rm -rf ./bower_components

