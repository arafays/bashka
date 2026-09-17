BIN := target/release/bashka
JS := node

.PHONY: build test corpus clippy fmt run-example validate clean next-version pin-installer

build:
	cargo build --release

test:
	cargo test

clippy:
	cargo clippy --all-targets

fmt:
	cargo fmt

check: build
	$(BIN) --check < $(FILE)

validate: build
	$(JS) scripts/validate_installers.js --markdown docs/validation.md

clean:
	cargo clean

# Release helpers used by .github/workflows/release.yml; runnable locally for a dry run.
next-version:
	cargo set-version --bump minor --dry-run

TARGETS := x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu x86_64-unknown-linux-musl \
           aarch64-unknown-linux-musl aarch64-linux-android x86_64-apple-darwin aarch64-apple-darwin
FORMULA := Formula/bashka.rb
SHA256 := $(shell command -v sha256sum >/dev/null && echo sha256sum || echo "shasum -a 256")
pin-installer:
	@test -n "$(VERSION)" && test -n "$(BINARIES_DIR)" || { echo "usage: make pin-installer VERSION=0.3.0 BINARIES_DIR=./binaries"; exit 1; }
	@for t in $(TARGETS); do test -f "$(BINARIES_DIR)/bashka-$$t" || { echo "missing $(BINARIES_DIR)/bashka-$$t"; exit 1; }; done
	@sed -i -e 's|^PINNED_RELEASE_TAG=.*|PINNED_RELEASE_TAG="v$(VERSION)"|' install.sh
	@for t in $(TARGETS); do \
	  var="SHA256_$$(echo "$$t" | tr 'a-z-' 'A-Z_')"; \
	  sha="$$($(SHA256) "$(BINARIES_DIR)/bashka-$$t" | cut -d' ' -f1)"; \
	  sed -i -e "s|^$$var=.*|$$var=\"$$sha\"|" install.sh; \
	  grep -q "^$$var=\"$$sha\"$$" install.sh || { echo "install.sh has no $$var line"; exit 1; }; \
	done
	@echo "install.sh pinned to v$(VERSION)"
	@sed -i -e 's|^\(  version \)".*"|\1"$(VERSION)"|' \
	        -e 's|/releases/download/v[^/]*/|/releases/download/v$(VERSION)/|' $(FORMULA)
	@for t in $(TARGETS); do \
	  grep -q "bashka-$$t\"" $(FORMULA) || continue; \
	  sha="$$($(SHA256) "$(BINARIES_DIR)/bashka-$$t" | cut -d' ' -f1)"; \
	  sed -i -e "/bashka-$$t\"/{n;s|sha256 \".*\"|sha256 \"$$sha\"|;}" $(FORMULA); \
	  grep -q "sha256 \"$$sha\"" $(FORMULA) || { echo "$(FORMULA) has no sha256 line after bashka-$$t"; exit 1; }; \
	done
	@! command -v ruby >/dev/null || ruby -c $(FORMULA) >/dev/null
	@echo "$(FORMULA) pinned to v$(VERSION)"
