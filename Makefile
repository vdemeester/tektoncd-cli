YAML_FILES := $(shell find . -type f -regex ".*y[a]ml" -print)
MODULE     = $(shell env GO111MODULE=on $(GO) list -m)
DATE      ?= $(shell date +%FT%T%z)
VERSION   ?= $(shell git describe --tags --always --dirty --match=v* 2> /dev/null || \
			cat $(CURDIR)/.version 2> /dev/null || echo v0)
PKGS       = $(or $(PKG),$(shell env GO111MODULE=on $(GO) list ./...))
TESTPKGS   = $(shell env GO111MODULE=on $(GO) list -f \
			'{{ if or .TestGoFiles .XTestGoFiles }}{{ .ImportPath }}{{ end }}' \
			$(PKGS))
TOOLS_BIN  = $(CURDIR)/.bin

GOLANGCI_VERSION = v1.24.0

GO           = go
TIMEOUT_UNIT = 5m
TIMEOUT_E2E  = 20m
V = 0
Q = $(if $(filter 1,$V),,@)
M = $(shell printf "\033[34;1m🐱\033[0m")

ifneq (,$(wildcard ./VERSION))
LDFLAGS := -ldflags "-X github.com/tektoncd/cli/pkg/cmd/version.clientVersion=`cat VERSION`"
endif

ifneq ($(RELEASE_VERSION),)
LDFLAGS := -ldflags "-X github.com/tektoncd/cli/pkg/cmd/version.clientVersion=$(RELEASE_VERSION)"
endif

$(TOOLS_BIN):
	@mkdir -p $@
$(TOOLS_BIN)/%: | $(TOOLS_BIN) ; $(info $(M) building $(PACKAGE)…)
	$Q tmp=$$(mktemp -d); \
	   env GO111MODULE=off GOPATH=$$tmp GOBIN=$(TOOLS_BIN) $(GO) get $(PACKAGE) \
		|| ret=$$?; \
	   rm -rf $$tmp ; exit $$ret

all: bin/tkn test

FORCE:

vendor:
	@go mod vendor

.PHONY: cross
cross: amd64 386 arm arm64 ## build cross platform binaries

.PHONY: amd64
amd64:
	GOOS=linux GOARCH=amd64 go build -mod=vendor $(LDFLAGS) -o bin/tkn-linux-amd64 ./cmd/tkn
	GOOS=windows GOARCH=amd64 go build -mod=vendor $(LDFLAGS) -o bin/tkn-windows-amd64 ./cmd/tkn
	GOOS=darwin GOARCH=amd64 go build -mod=vendor $(LDFLAGS) -o bin/tkn-darwin-amd64 ./cmd/tkn

.PHONY: 386
386:
	GOOS=linux GOARCH=386 go build -mod=vendor $(LDFLAGS) -o bin/tkn-linux-386 ./cmd/tkn
	GOOS=windows GOARCH=386 go build -mod=vendor $(LDFLAGS) -o bin/tkn-windows-386 ./cmd/tkn
	GOOS=darwin GOARCH=386 go build -mod=vendor $(LDFLAGS) -o bin/tkn-darwin-386 ./cmd/tkn

.PHONY: arm
arm:
	GOOS=linux GOARCH=arm go build -mod=vendor $(LDFLAGS) -o bin/tkn-linux-arm ./cmd/tkn

.PHONY: arm64
arm64:
	GOOS=linux GOARCH=arm64 go build -mod=vendor $(LDFLAGS) -o bin/tkn-linux-arm64 ./cmd/tkn

$(BIN)/%: cmd/% FORCE
	go build -mod=vendor $(LDFLAGS) -v -o $@ ./$<

check: lint test

.PHONY: test
test: test-unit ## run all tests

RAM = $(TOOLS_BIN)/ram
$(TOOLS_BIN)/ram: PACKAGE=github.com/vdemeester/ram

.PHONY: watch-test
watch-test: | $(RAM) ; $(info $(M) watch and run tests) @ ## Watch and run tests
	$Q $(RAM) -- -failfast

GOLANGCILINT= $(TOOLS_BIN)/golangci-lint
$(TOOLS_BIN)/golangci-lint: ; $(info $(M) getting golangci-lint $(GOLANGCI_VERSION))
	@curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(TOOLS_BIN) $(GOLANGCI_VERSION)

.PHONY: golangci-lint
golangci-lint: | $(GOLANGCILINT) ; $(info $(M) running golangci-lint) @ ## Run golangci-lint
	$Q $(GOLANGCILINT) run --modules-download-mode=vendor --max-issues-per-linter=0 --max-same-issues=0 --deadline 5m

.PHONY: lint
lint: golangci-lint lint-yaml ## run linter(s)
	$Q $(GOLANGCILINT) run ./... --modules-download-mode=vendor \
								--max-issues-per-linter=0 \
								--max-same-issues=0 \
								--deadline 5m

.PHONY: lint-yaml
lint-yaml: ${YAML_FILES} ## runs yamllint on all yaml files
	@yamllint -c .yamllint $(YAML_FILES)

.PHONY: test-unit
test-unit: ./vendor ## run unit tests
	@echo "Running unit tests..."
	@go test -failfast -v -cover ./...

.PHONY: test-unit-update-golden
test-unit-update-golden: ./vendor ## run unit tests (updating golden files)
	@echo "Running unit tests updating golden files..."
	@./hack/update-golden.sh

.PHONY: test-e2e
test-e2e: bin/tkn ## run e2e tests
	@echo "Running e2e tests..."
	@LOCAL_CI_RUN=true bash ./test/e2e-tests.sh

.PHONY: docs
docs: bin/docs ## update docs
	@echo "Update generated docs"
	@./bin/docs --target=./docs/cmd
	@./bin/docs --target=./docs/man/man1 --kind=man
	@rm -f ./bin/docs

.PHONY: generated
generated: test-unit-update-golden docs fmt ## generate all files that needs to be generated

.PHONY: clean
clean: ## clean build artifacts
	rm -fR bin VERSION $(TOOLS_BIN)

.PHONY: fmt ## formats the GO code(excludes vendors dir)
fmt:
	@go fmt `go list ./... | grep -v /vendor/`

.PHONY: help
help: ## print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {gsub("\\\\n",sprintf("\n%22c",""), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
