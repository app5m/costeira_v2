#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Iniciando build iOS${NC}"

MODE="${1:-prod}"  # dev | prod

echo -e "${YELLOW}Limpando o projeto...${NC}"
flutter clean

echo -e "${YELLOW}Obtendo dependências...${NC}"
flutter pub get

if [ "$MODE" == "dev" ]; then
  echo -e "${YELLOW}Build iOS para SIMULADOR (debug)${NC}"
  flutter build ios --simulator --debug
else
  echo -e "${YELLOW}Build iOS para DEVICE (release, sem codesign)${NC}"
  flutter build ios --release --no-codesign
fi

echo -e "${YELLOW}Abrindo o Xcode...${NC}"
cd ios
open Runner.xcworkspace

echo -e "${GREEN}Pronto.${NC}"
if [ "$MODE" != "dev" ]; then
  echo -e "${YELLOW}No Xcode (para gerar IPA):${NC}"
  echo -e "1) Selecione 'Any iOS Device (arm64)'"
  echo -e "2) Product > Archive"
  echo -e "3) Distribute App (export IPA/TestFlight/etc)"
fi
