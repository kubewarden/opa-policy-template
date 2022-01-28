# opa-policy-template

This is a template repository that can be used to easily convert an existing
Rego policy targeting the Open Policy Agent framework into a Kubewarden policy.

Don't forget to checkout Kubewarden's [official documentation](https://docs.kubewarden.io)
for more information about writing policies.

## Introduction

**Note well:** the existing Rego code should not need to be rewritten.

These are the only requirements you have to fulfill:

1. The policy evaluation must return a `AdmissionReview` response object. This
  is already a requirement for all the Open Policy Agent policies that are meant
  to be used with Kubernetes.
1. The policy must be compiled into a WebAssembly module using the `opa` cli tool.
1. The policy must be annotated via `kwctl annotate`.

This template repository contains an example policy that can be used as foundation
for your policies, plus all the automation needed to implement the 2nd and 3rd points.

## Implementation details

The actual policy is defined inside of the `policy.rego` file. This file defines
a `deny` object that is later embedded into an `AdmissionReview` response.

The `AdmissionReview` object is defined inside of the `utility/policy.rego` file.
You probably won't need to change this file.

## Testing

The policy has some unit tests written using Rego, they can be found inside of
the file `policy_test.rego`. The unit tests can be executed via the following
command:

```shell
make test
```

The repository provides also a way to run end-to-end tests against the WebAssembly
module produced by the compilation. These tests execute the policy using the
WebAssembly runtime of Kubewarden.

The e2e tests are implemented using [bats](https://github.com/bats-core/bats-core):
the Bash Automated Testing System. The WebAssembly runtime is provided by the
[kwctl](https://github.com/kubewarden/kwctl) cli tool.

The end-to-end tests are defined inside of the `e2e.bats` file and can
be run via this command:

```shell
make e2e-tests
```

## Automation

This project contains [GitHub Actions](https://docs.github.com/en/actions)
workflows.

They take care of the following automations:

  * Execute the Rego test suite
  * Build the Rego files into a single WebAssembly module
  * Annotate the WebAssembly module with Kubewarden's metadata
  * Execute end-to-end tests
  * Push events on the `main` branch lead the:
    * Push the annotated WebAssembly module to the GitHub Container Registry using the
      `:latest` tag.
  * The creation of git tags lead to:
    * Creation of the GitHub Release, holding the annotated WebAssembly module
    * Push the annotated WebAssembly module to the GitHub Container Registry using the
      `:<git tag>` tag.
