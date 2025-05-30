SHELL := bash
.DELETE_ON_ERROR:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-print-directory
BIN := .tmp/bin
export PATH := $(BIN):$(PATH)
export GOBIN := $(abspath $(BIN))

.PHONY: help
help: ## Describe useful make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

$(BIN)/buf: Makefile
	@mkdir -p $(@D)
	@go install github.com/bufbuild/buf/cmd/buf@latest

.PHONY: generate-proto
generate-proto: $(BIN)/buf ## Generate protobuf files from module-registry-proto
	@echo "Copying proto files from ../module-registry-proto..."
	@mkdir -p .tmp/proto
	@cp -r ../module-registry-proto/* .tmp/proto
	@cp buf.gen.yaml .tmp/proto/buf.gen.yaml
	@echo "Running buf generate in .tmp..."
	@cd .tmp/proto && buf generate
	@echo "Copying generated files to root..."
	@cp -r .tmp/proto/gen/wippy/* ./
	@echo "Cleaning up tmp directory..."
	@rm -rf .tmp/proto
	@echo "Proto generation complete!"
