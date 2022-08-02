#!/usr/bin/env bash

set -e

# OSX GUI apps do not pick up environment variables the same way as Terminal apps and there are no easy solutions,
# especially as Apple changes the GUI app behavior every release (see https://stackoverflow.com/q/135688/483528). As a
# workaround to allow GitHub Desktop to work, add this (hopefully harmless) setting here.
export PATH=${PATH}:/usr/local/bin:/usr/bin

# File level checks
for file in "$@"; do
  tflint "${file}" \
    --enable-rule=terraform_deprecated_interpolation \
    --enable-rule=terraform_deprecated_index \
    --enable-rule=terraform_unused_declarations \
    --enable-rule=terraform_comment_syntax \
    --enable-rule=terraform_documented_outputs \
    --enable-rule=terraform_documented_variables \
    --enable-rule=terraform_typed_variables \
    --enable-rule=terraform_module_pinned_source \
    --enable-rule=terraform_naming_convention \
    --enable-rule=terraform_required_version \
    --enable-rule=terraform_workspace_remote
done
#    --enable-rule=terraform_required_providers \

# Folder level checks
for dir in $(echo "$@" | xargs -n1 dirname | sort -u | uniq); do
  pushd "${dir}" >/dev/null
  tflint --enable-rule=terraform_standard_module_structure
  popd >/dev/null
done
