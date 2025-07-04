# Adapted from github.com/temporalio/api

$(VERBOSE).SILENT:
############################# Main targets #############################
ci-build: install proto

# Install dependencies.
install: grpc-install api-linter-install buf-install

# Run all linters and compile proto files.
proto: grpc
########################################################################

##### Variables ######
ifndef GOPATH
GOPATH := $(shell go env GOPATH)
endif

GOBIN := $(if $(shell go env GOBIN),$(shell go env GOBIN),$(GOPATH)/bin)

COLOR := "\e[1;36m%s\e[0m\n"

PROTO_ROOT := proto
PROTO_FILES = $(shell find $(PROTO_ROOT) -name "*.proto")
PROTO_DIRS = $(sort $(dir $(PROTO_FILES)))
PROTO_OUT := gen

$(PROTO_OUT):
	mkdir $(PROTO_OUT)

##### Compile proto files for go #####
grpc: buf-lint buf-generate

grpc-install: buf-install api-linter-install

.PHONY: buf-generate
buf-generate: install
	printf $(COLOR) "Run buf generate..."
	(cd $(PROTO_ROOT) && buf generate)

##### Plugins & tools #####
api-linter-install:
	printf $(COLOR) "Install/update api-linter..."
	go install github.com/googleapis/api-linter/cmd/api-linter@v1.22.0

buf-install:
	printf $(COLOR) "Install/update buf..."
	go install github.com/bufbuild/buf/cmd/buf@v1.37.0

##### Linters #####
api-linter:
	printf $(COLOR) "Run api-linter..."
	api-linter --set-exit-status --config $(PROTO_ROOT)/api-linter.yaml $(PROTO_FILES)

buf-lint:
	printf $(COLOR) "Run buf linter..."
	(cd $(PROTO_ROOT) && buf lint)

buf-breaking:
	printf $(COLOR) "Run buf breaking changes check against main branch..."
	(cd $(PROTO_ROOT) && buf breaking --against '.git#branch=main')

##### Clean #####
clean:
	printf $(COLOR) "Delete generated go files..."
	rm -rf $(PROTO_OUT)
