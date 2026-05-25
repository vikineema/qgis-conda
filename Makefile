#!make
SHELL := /usr/bin/env bash

run-pre-commit:
	@echo "Running pre-commit checks..."
	pre-commit clean > /dev/null
	pre-commit install --install-hooks > /dev/null
	pre-commit run --all-files || true
	@echo "Pre-commit checks complete. Happy coding! 🚀"
