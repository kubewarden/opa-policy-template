SOURCE_FILES := $(shell find . -type f -name '*.rego')
VERSION := $(shell git describe --exact-match --tags $(git log -n1 --pretty='%h') | cut -c2-)

policy.wasm: $(SOURCE_FILES)
	opa build -t wasm -e policy/main utility/policy.rego -o bundle.tar.gz policy.rego
	tar xvf bundle.tar.gz /policy.wasm
	rm bundle.tar.gz
	touch policy.wasm # opa creates the bundle with unix epoch timestamp, fix it

.PHONY: test
test:
	opa test *.rego

artifacthub-pkg.yml: metadata.yml
	kwctl scaffold artifacthub \
	    --metadata-path metadata.yml --version $(VERSION) \
		--questions-path questions-ui.yml > artifacthub-pkg.yml.tmp \
	&& mv artifacthub-pkg.yml.tmp artifacthub-pkg.yml \
	|| rm -f artifacthub-pkg.yml.tmp

annotated-policy.wasm: policy.wasm metadata.yml artifacthub-pkg.yml
	kwctl annotate -m metadata.yml -u README.md -o annotated-policy.wasm policy.wasm

.PHONY: e2e-tests
e2e-tests: annotated-policy.wasm
	bats e2e.bats

.PHONY: clean
clean:
	rm -f *.wasm *.tar.gz
