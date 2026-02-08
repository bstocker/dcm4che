SHELL := /usr/bin/env bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

JDK17_HOME := /usr/lib/jvm/java-17-openjdk-amd64
DCM4CHE_DIR := /workspaces/dcm4che
ASSEMBLY_ZIP := $(DCM4CHE_DIR)/dcm4che-assembly/target/dcm4che-*-bin.zip
ASSEMBLY_DIR := $(DCM4CHE_DIR)/dcm4che-assembly/target

.PHONY: all prereq java17 build unzip env help

all: prereq java17 build unzip env

help:
	@echo "Targets:"
	@echo "  make prereq   # disable Yarn repo if it breaks apt update"
	@echo "  make java17   # install & select Java 17"
	@echo "  make build    # build dcm4che assembly"
	@echo "  make unzip    # unzip bin distribution"
	@echo "  make env      # prints command to add dcm4che bin to PATH"
	@echo "  make all      # run everything"

prereq:
	@echo "[prereq] Disabling Yarn repo if present (avoids NO_PUBKEY)..."
	sudo sed -i 's/^[[:space:]]*deb /# deb /' /etc/apt/sources.list.d/yarn.list 2>/dev/null || true

java17:
	@echo "[java17] apt update + install openjdk-17-jdk..."
	sudo apt-get update
	sudo apt-get install -y openjdk-17-jdk unzip
	@echo "[java17] set alternatives..."
	sudo update-alternatives --set java  $(JDK17_HOME)/bin/java
	sudo update-alternatives --set javac $(JDK17_HOME)/bin/javac
	@echo "[java17] export env for this make run..."
	export JAVA_HOME=$(JDK17_HOME)
	export PATH="$$JAVA_HOME/bin:/usr/bin:$$PATH"
	hash -r
	java -version
	javac -version

build:
	@echo "[build] Building dcm4che assembly..."
	cd "$(DCM4CHE_DIR)"
	export JAVA_HOME=$(JDK17_HOME)
	export PATH="$$JAVA_HOME/bin:/usr/bin:$$PATH"
	./mvnw -DskipTests install -pl dcm4che-assembly -am

unzip:
	@echo "[unzip] Unzipping dcm4che bin distribution..."
	cd "$(ASSEMBLY_DIR)"
	ZIP=$$(ls -1 dcm4che-*-bin.zip | head -n 1)
	unzip -o "$$ZIP" >/dev/null
	ls -la dcm4che-*/bin | head -n 15

env:
	@echo
	@echo "To use dcm2jpg in your current terminal, run:"
	@echo "  BIN_DIR=\"$$(ls -d $(ASSEMBLY_DIR)/dcm4che-*/bin | head -n 1)\""
	@echo "  export PATH=\"$$BIN_DIR:$$PATH\""
	@echo "  hash -r"
	@echo "  dcm2jpg -h"
