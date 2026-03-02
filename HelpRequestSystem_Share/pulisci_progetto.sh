#!/bin/bash

echo "🧹 PULIZIA PROGETTO - File Eliminabili"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Calcola spazio attuale
echo -e "${BLUE}Calcolo spazio occupato...${NC}"
echo ""

SPACE_BIN_CLIENT=$(du -sh Client/bin 2>/dev/null | cut -f1)
SPACE_OBJ_CLIENT=$(du -sh Client/obj 2>/dev/null | cut -f1)
SPACE_BIN_SERVER=$(du -sh Server/bin 2>/dev/null | cut -f1)
SPACE_OBJ_SERVER=$(du -sh Server/obj 2>/dev/null | cut -f1)

echo "📊 Spazio occupato:"
[ -d "Client/bin" ] && echo "  Client/bin: $SPACE_BIN_CLIENT"
[ -d "Client/obj" ] && echo "  Client/obj: $SPACE_OBJ_CLIENT"
[ -d "Server/bin" ] && echo "  Server/bin: $SPACE_BIN_SERVER"
[ -d "Server/obj" ] && echo "  Server/obj: $SPACE_OBJ_SERVER"

echo ""
echo "File temporanei:"
[ -f "Client/client_config.json.backup" ] && echo "  ✓ Client/client_config.json.backup"
[ -f "Server/server_config.json.backup" ] && echo "  ✓ Server/server_config.json.backup"
[ -f "Client/client_log.txt" ] && echo "  ✓ Client/client_log.txt"
[ -f "Server/server_log.txt" ] && echo "  ✓ Server/server_log.txt"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}⚠️  COSA VUOI ELIMINARE?${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  1) Solo cartelle bin/ e obj/ (recupera ~1GB)"
echo "  2) Solo file temporanei (backup, log)"
echo "  3) Tutto (bin/, obj/, backup, log)"
echo "  4) Niente (esci)"
echo ""

read -p "Scegli [1-4]: " CHOICE

echo ""

case $CHOICE in
    1)
        echo -e "${BLUE}Eliminazione cartelle di compilazione...${NC}"
        rm -rf Client/bin Client/obj Server/bin Server/obj
        echo -e "${GREEN}✓ Cartelle bin/ e obj/ eliminate${NC}"
        echo "  (Si rigenerano con: dotnet build)"
        ;;
    2)
        echo -e "${BLUE}Eliminazione file temporanei...${NC}"
        rm -f Client/client_config.json.backup
        rm -f Server/server_config.json.backup
        rm -f Client/client_log.txt
        rm -f Server/server_log.txt
        echo -e "${GREEN}✓ File temporanei eliminati${NC}"
        ;;
    3)
        echo -e "${BLUE}Pulizia completa...${NC}"
        # Cartelle compilazione
        rm -rf Client/bin Client/obj Server/bin Server/obj
        # File temporanei
        rm -f Client/client_config.json.backup
        rm -f Server/server_config.json.backup
        rm -f Client/client_log.txt
        rm -f Server/server_log.txt
        
        echo -e "${GREEN}✓ Pulizia completa eseguita${NC}"
        echo "  • Cartelle bin/obj eliminate"
        echo "  • File backup eliminati"
        echo "  • File log eliminati"
        ;;
    4)
        echo "Nessuna modifica effettuata."
        exit 0
        ;;
    *)
        echo -e "${RED}✗ Opzione non valida${NC}"
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ PULIZIA COMPLETATA${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}💡 Note:${NC}"
echo "  • bin/obj si rigenerano con: dotnet build"
echo "  • Log si rigenerano all'avvio delle app"
echo "  • Backup erano copie temporanee dei test"
echo ""
