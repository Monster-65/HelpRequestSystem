#!/bin/bash

echo "🔧 CAMBIO PORTA SERVER - Prova porte comuni"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "Porte comunemente aperte su Windows (senza modificare firewall):"
echo ""
echo "  [1] 8080  - HTTP alternativo (consigliata)"
echo "  [2] 8008  - HTTP alternativo"
echo "  [3] 5000  - Sviluppo ASP.NET"
echo "  [4] 5001  - Sviluppo ASP.NET (HTTPS)"
echo "  [5] 3000  - Sviluppo web generico"
echo "  [6] 9090  - Porta alta (meno bloccata)"
echo "  [7] 7777  - Mantieni attuale (richiede configurazione firewall)"
echo "  [8] Altra porta personalizzata"
echo ""

read -p "Scegli un'opzione [1-8]: " CHOICE

case $CHOICE in
    1) NEW_PORT="8080" ;;
    2) NEW_PORT="8008" ;;
    3) NEW_PORT="5000" ;;
    4) NEW_PORT="5001" ;;
    5) NEW_PORT="3000" ;;
    6) NEW_PORT="9090" ;;
    7) NEW_PORT="7777" ;;
    8) 
        read -p "Inserisci la porta (1024-65535): " NEW_PORT
        if ! [[ "$NEW_PORT" =~ ^[0-9]+$ ]] || [ "$NEW_PORT" -lt 1024 ] || [ "$NEW_PORT" -gt 65535 ]; then
            echo -e "${RED}✗ Porta non valida${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}✗ Scelta non valida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Nuova porta selezionata:${NC} $NEW_PORT"
echo ""

# Aggiorna configurazione server
SERVER_CONFIG="/home/king_monster_/Scrivania/HelpRequestSystem/Server/server_config.json"
CLIENT_CONFIG="/home/king_monster_/Scrivania/HelpRequestSystem/Client/client_config.json"

echo -e "${BLUE}[1/3]${NC} Aggiornamento configurazione server..."

if [ -f "$SERVER_CONFIG" ]; then
    # Backup
    cp "$SERVER_CONFIG" "${SERVER_CONFIG}.backup"
    
    # Aggiorna porta
    sed -i "s/\"ServerPort\": \"[^\"]*\"/\"ServerPort\": \"$NEW_PORT\"/" "$SERVER_CONFIG"
    
    echo -e "${GREEN}✓ server_config.json aggiornato${NC}"
    echo "   ServerPort: $NEW_PORT"
else
    echo -e "${RED}✗ server_config.json non trovato${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[2/3]${NC} Aggiornamento configurazione client..."

if [ -f "$CLIENT_CONFIG" ]; then
    # Backup
    cp "$CLIENT_CONFIG" "${CLIENT_CONFIG}.backup"
    
    # Aggiorna porta
    sed -i "s/\"ServerPort\": \"[^\"]*\"/\"ServerPort\": \"$NEW_PORT\"/" "$CLIENT_CONFIG"
    
    echo -e "${GREEN}✓ client_config.json aggiornato${NC}"
    echo "   ServerPort: $NEW_PORT"
else
    echo -e "${RED}✗ client_config.json non trovato${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[3/3]${NC} Aggiornamento build Windows..."

# Aggiorna anche i file nella build Windows se esistono
WIN_SERVER_CONFIG="/home/king_monster_/Scrivania/HelpRequestSystem/build_windows/Server/server_config.json"
WIN_CLIENT_CONFIG="/home/king_monster_/Scrivania/HelpRequestSystem/build_windows/Client/client_config.json"

if [ -f "$WIN_SERVER_CONFIG" ]; then
    cp "$WIN_SERVER_CONFIG" "${WIN_SERVER_CONFIG}.backup"
    sed -i "s/\"ServerPort\": \"[^\"]*\"/\"ServerPort\": \"$NEW_PORT\"/" "$WIN_SERVER_CONFIG"
    echo -e "${GREEN}✓ Build Windows server aggiornata${NC}"
fi

if [ -f "$WIN_CLIENT_CONFIG" ]; then
    cp "$WIN_CLIENT_CONFIG" "${WIN_CLIENT_CONFIG}.backup"
    sed -i "s/\"ServerPort\": \"[^\"]*\"/\"ServerPort\": \"$NEW_PORT\"/" "$WIN_CLIENT_CONFIG"
    echo -e "${GREEN}✓ Build Windows client aggiornata${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ PORTA CAMBIATA CON SUCCESSO!${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📋 PROSSIMI PASSI:${NC}"
echo ""
echo "1️⃣  SUL PC WINDOWS (Server):"
echo "    • Se hai già la build, copia il nuovo server_config.json:"
echo "      cp build_windows/Server/server_config.json → PC Windows"
echo "    • OPPURE ri-compila per Windows:"
echo "      sudo ./build_windows.sh"
echo "    • Avvia il server: start_server.bat"
echo "    • Il server ora ascolterà sulla porta $NEW_PORT"
echo ""
echo "2️⃣  TEST CONNETTIVITÀ (da questo PC Linux):"
echo "    • Prima prova con telnet:"
echo "      telnet 192.168.0.114 $NEW_PORT"
echo "    • Se si connette → la porta è aperta!"
echo "    • Se NON si connette → prova un'altra porta"
echo ""
echo "3️⃣  SUL PC LINUX (Client - questo PC):"
echo "    • La configurazione è già aggiornata"
echo "    • Avvia il client:"
echo "      cd Client && ./start_client.sh"
echo "    • Invia una richiesta di test"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}💡 Note importanti:${NC}"
echo ""

if [ "$NEW_PORT" = "8080" ] || [ "$NEW_PORT" = "8008" ]; then
    echo -e "${GREEN}✓${NC} Porta $NEW_PORT è comunemente usata per HTTP alternativo"
    echo "  Ha buone probabilità di essere aperta nel firewall Windows"
elif [ "$NEW_PORT" -ge 5000 ] && [ "$NEW_PORT" -le 5100 ]; then
    echo -e "${GREEN}✓${NC} Porta $NEW_PORT è spesso usata per sviluppo"
    echo "  Visual Studio e ASP.NET usano questo range"
elif [ "$NEW_PORT" -ge 3000 ] && [ "$NEW_PORT" -le 3100 ]; then
    echo -e "${GREEN}✓${NC} Porta $NEW_PORT è usata da molti framework web"
    echo "  (Node.js, React, etc.) - potrebbe essere aperta"
elif [ "$NEW_PORT" -ge 8000 ] && [ "$NEW_PORT" -le 9000 ]; then
    echo -e "${YELLOW}⚠${NC} Porta $NEW_PORT è in un range comune"
    echo "  Ma potrebbe richiedere configurazione firewall"
else
    echo -e "${YELLOW}⚠${NC} Porta $NEW_PORT potrebbe richiedere configurazione firewall"
fi

echo ""
echo "  Per testare se la porta è aperta DOPO aver avviato il server Windows:"
echo "    telnet 192.168.0.114 $NEW_PORT"
echo ""
echo "  Backup salvati in:"
echo "    • server_config.json.backup"
echo "    • client_config.json.backup"
echo ""
echo "  Per ripristinare la porta precedente:"
echo "    cp Server/server_config.json.backup Server/server_config.json"
echo "    cp Client/client_config.json.backup Client/client_config.json"
echo ""
