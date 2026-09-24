#!/bin/bash
set -e

cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

MODE="${1:-prod}"  # dev | prod

VERSION_LINE=$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')
VERSION_NAME="${VERSION_LINE%%+*}"
VERSION_CODE="${VERSION_LINE##*+}"

echo -e "${YELLOW}Costeira iOS build${NC}"
echo -e "Versao: ${GREEN}${VERSION_NAME}${NC} (build ${GREEN}${VERSION_CODE}${NC})"
echo -e "Modo: ${GREEN}${MODE}${NC}"

if ! command -v flutter >/dev/null 2>&1; then
  echo -e "${RED}flutter nao encontrado no PATH${NC}"
  exit 1
fi

echo -e "${YELLOW}Limpando o projeto...${NC}"
flutter clean

echo -e "${YELLOW}Obtendo dependencias...${NC}"
flutter pub get

echo -e "${YELLOW}Instalando pods...${NC}"
cd ios
pod install
cd ..

if [ "$MODE" == "dev" ]; then
  echo -e "${YELLOW}Build iOS para SIMULADOR (debug)${NC}"
  flutter build ios --simulator --debug
else
  echo -e "${YELLOW}Build iOS para DEVICE (release, sem codesign)${NC}"
  flutter build ios --release --no-codesign
fi

echo -e "${YELLOW}Abrindo o Xcode...${NC}"
open ios/Runner.xcworkspace

echo -e "${GREEN}Pronto.${NC}"
if [ "$MODE" != "dev" ]; then
  echo -e "${YELLOW}No Xcode (para gerar IPA):${NC}"
  echo -e "1) Selecione 'Any iOS Device (arm64)'"
  echo -e "2) Product > Archive"
  echo -e "3) Distribute App (export IPA/TestFlight/etc)"
fi
