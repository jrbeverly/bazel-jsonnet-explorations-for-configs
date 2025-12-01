.PHONY: setup e2e

BAZEL := $(or $(shell command -v bazelisk 2>/dev/null),$(CURDIR)/bin/bazelisk)

$(CURDIR)/bin/bazelisk:
	mkdir -p $(dir $@)
	curl -fsSL -o $@ https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64
	chmod +x $@

setup: $(if $(shell command -v bazelisk 2>/dev/null),,$(CURDIR)/bin/bazelisk)
	$(BAZEL) fetch //...

e2e: setup
	BAZEL=$(BAZEL) bash e2e.sh
