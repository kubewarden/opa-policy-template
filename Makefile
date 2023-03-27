SOURCE_FILES := $(shell find . -type f -name '*.rego')
# It's necessary to call cut because kwctl command does not handle version
# starting with v.
VERSION ?= $(shell git describe | cut -c2-)

policy.wasm: $(SOURCE_FILES)
	opa build -t wasm -e policy/main utility/policy.rego -o bundle.tar.gz policy.rego
	tar xvf bundle.tar.gz /policy.wasm
	rm bundle.tar.gz
	touch policy.wasm # opa creates the bundle with unix epoch timestamp, fix it

.PHONY: test
test:
	opa test *.rego

artifacthub-pkg.yml: metadata.yml
	$(warning If you are updating the artifacthub-pkg.yml file for a release, \
	  remember to set the VERSION variable with the proper value. \
	  To use the latest tag, use the following command:  \
	  make VERSION=$$(git describe --tags --abbrev=0 | cut -c2-) annotated-policy.wasm)
	kwctl scaffold artifacthub \
	  --metadata-path metadata.yml --version $(VERSION) \
	  --output artifacthub-pkg.yml

annotated-policy.wasm: policy.wasm metadata.yml artifacthub-pkg.yml
	kwctl annotate -m metadata.yml -u README.md -o annotated-policy.wasm policy.wasm

.PHONY: e2e-tests
e2e-tests: annotated-policy.wasm
	bats e2e.bats

.PHONY: clean
clean:
	rm -f *.wasm *.tar.gz
