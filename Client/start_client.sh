#!/bin/bash

echo "💻 Avvio Client Help Request System"
echo "===================================="
echo ""

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifica se siamo nella directory corretta
if [ ! -f "Client.csproj" ]; then
    echo -e "${RED}Errore: Esegui questo script dalla directory Client!${NC}"
    echo "cd /home/king_monster_/Scrivania/HelpRequestSystem/Client"
    exit 1
fi

# Build del progetto
echo "🔨 Compilazione del progetto..."
dotnet build -c Release

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Errore durante la compilazione!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Compilazione completata${NC}"
echo ""

echo -e "${YELLOW}📝 Ricorda di inserire l'IP del server nell'interfaccia!${NC}"
echo ""

# Avvio del client
echo "🚀 Avvio del client..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

dotnet run -c Release

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Client terminato."
