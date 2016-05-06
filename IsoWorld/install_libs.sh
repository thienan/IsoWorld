#!/usr/bin/env bash

# Check updates of frameworks
carthage outdated

# Install latest frameworks
carthage update --no-use-binaries --platform iOS
