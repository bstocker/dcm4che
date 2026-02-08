#!/usr/bin/env bash
set -euo pipefail

# ---- Config
JDK17_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# ---- Must run from dcm4che repo root (where mvnw exists)
if [[ ! -f "./mvnw" ]]; then
  echo "ERROR: ./mvnw not found. Run this script from the dcm4che repo root."
  exit 1
fi

echo "[1/6] Installing Java 17..."
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk unzip

echo "[2/6] Setting system alternatives to Java 17..."
sudo update-alternatives --set java  "$JDK17_HOME/bin/java"
sudo update-alternatives --set javac "$JDK17_HOME/bin/javac"

echo "[3/6] Exporting JAVA_HOME and PATH for current shell..."
export JAVA_HOME="$JDK17_HOME"
export PATH="$JAVA_HOME/bin:/usr/bin:$PATH"
hash -r

echo "    java:  $(command -v java)"
echo "    javac: $(command -v javac)"
java -version
javac -version

echo "[4/6] Building dcm4che assembly (bin distribution)..."
./mvnw -DskipTests install -pl dcm4che-assembly -am

echo "[5/6] Unzipping the bin distribution..."
ZIP_PATH="$(ls -1 dcm4che-assembly/target/dcm4che-*-bin.zip | head -n 1)"
if [[ -z "${ZIP_PATH:-}" ]]; then
  echo "ERROR: Could not find dcm4che-*-bin.zip under dcm4che-assembly/target"
  exit 1
fi
unzip -o "$ZIP_PATH" -d dcm4che-assembly/target >/dev/null

echo "[6/6] Exposing bin directory..."
# The unzip creates dcm4che-<version>/bin under dcm4che-assembly/target
BIN_DIR="$(ls -d "$PWD"/dcm4che-assembly/target/dcm4che-*/bin | head -n 1)"
if [[ ! -d "$BIN_DIR" ]]; then
  echo "ERROR: BIN_DIR not found after unzip: $BIN_DIR"
  exit 1
fi

export PATH="$BIN_DIR:$PATH"
hash -r

echo
echo "✅ Done."
echo "BIN_DIR=$BIN_DIR"
echo "Try: dcm2jpg -h"
