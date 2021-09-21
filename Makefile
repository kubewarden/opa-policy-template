wasm: 
	opa build -t wasm -e policy/main utility/policy.rego -o bundle.tar.gz policy.rego
	tar xvf bundle.tar.gz /policy.wasm
	rm bundle.tar.gz

test:
	opa test *.rego

annotate: wasm
	kwctl annotate -m metadata.yml -o annotated.wasm policy.wasm

e2e-tests:
	bats e2e.bats

clean:
	rm -f *.wasm *.tar.gz
