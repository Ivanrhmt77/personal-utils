#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m'

javac -d bin $(find src -name "*.java")

if [ $? -ne 0 ]; then
    echo "❌ Kompilasi gagal."
    exit 1
fi

MAIN_CLASS=$(grep -rl "public static void main" src | sed 's/src\///; s/\.java//; s/\//./g')

if [ -n "$MAIN_CLASS" ]; then
    java -cp bin "$MAIN_CLASS"
else
    echo "❌ Tidak menemukan class dengan method main."
fi
