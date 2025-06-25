OPA_V0_COMPATIBLE ?= false
SOURCE_FILES := $(shell find . -type f -name '*.rego')

policy.wasm: $(SOURCE_FILES)
ifeq ($(OPA_V0_COMPATIBLE), true)
	opa build --v0-compatible -t wasm -e policy/main utility/policy.rego -o bundle.tar.gz policy.rego
else
	opa build -t wasm -e policy/main utility/policy.rego -o bundle.tar.gz policy.rego
endif
	tar xvf bundle.tar.gz /policy.wasm
	rm bundle.tar.gz
	touch policy.wasm # opa creates the bundle with unix epoch timestamp, fix it

.PHONY: test
test:
ifeq ($(OPA_V0_COMPATIBLE), true)
	opa test --v0-compatible *.rego
else
	opa test *.rego
endif

annotated-policy.wasm: policy.wasm metadata.yml
	kwctl annotate -m metadata.yml -u README.md -o annotated-policy.wasm policy.wasm

.PHONY: e2e-tests
e2e-tests: annotated-policy.wasm
	bats e2e.bats

.PHONY: clean
clean:
	rm -f *.wasm *.tar.gz
