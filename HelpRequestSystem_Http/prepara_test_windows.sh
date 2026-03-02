#!/bin/bash

echo "🔧 PREPARAZIONE TEST - Server Linux + Client Windows"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Trova IP
echo -e "${BLUE}[1/5]${NC} Rilevamento IP di rete..."
IP=$(hostname -I | awk '{print $1}')

if [ ! -z "$IP" ]; then
    echo -e "${GREEN}✓ IP rilevato: $IP${NC}"
    echo -e "${YELLOW}📋 Usa questo IP nel client Windows!${NC}"
else
    echo -e "${RED}✗ Impossibile rilevare IP${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[2/5]${NC} Verifica firewall..."

# Controlla se UFW è attivo
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(sudo ufw status | grep -i "Status: active")
    if [ ! -z "$UFW_STATUS" ]; then
        echo -e "${YELLOW}⚠ UFW firewall attivo${NC}"
        echo "   Consenti porta 7777:"
        echo "   $ sudo ufw allow 7777/tcp"
    else
        echo -e "${GREEN}✓ UFW non attivo o disabilitato${NC}"
    fi
else
    echo -e "   UFW non installato"
fi

# Controlla iptables
IPTABLES_RULE=$(sudo iptables -L INPUT -n | grep "7777")
if [ ! -z "$IPTABLES_RULE" ]; then
    echo -e "${GREEN}✓ Regola iptables per porta 7777 presente${NC}"
else
    echo -e "${YELLOW}⚠ Nessuna regola iptables per porta 7777${NC}"
    echo "   Aggiungi con:"
    echo "   $ sudo iptables -I INPUT -p tcp --dport 7777 -j ACCEPT"
fi

echo ""
echo -e "${BLUE}[3/5]${NC} Verifica server..."

# Controlla se il server è già in esecuzione
SERVER_RUNNING=$(ps aux | grep -i "Server" | grep -v grep | grep "dotnet")
if [ ! -z "$SERVER_RUNNING" ]; then
    echo -e "${GREEN}✓ Server già in esecuzione${NC}"
    
    # Verifica che stia ascoltando
    LISTENING=$(sudo netstat -tulpn 2>/dev/null | grep 7777)
    if [ ! -z "$LISTENING" ]; then
        echo -e "${GREEN}✓ Server in ascolto sulla porta 7777${NC}"
    else
        echo -e "${YELLOW}⚠ Server in esecuzione ma non in ascolto su 7777${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Server non in esecuzione${NC}"
    echo "   Avvia con: cd Server && sudo ./start_server.sh"
fi

echo ""
echo -e "${BLUE}[4/5]${NC} Configurazione client Windows..."

CLIENT_CONFIG="/home/king_monster_/Scrivania/HelpRequestSystem/build_windows/Client/client_config.json"

if [ -f "$CLIENT_CONFIG" ]; then
    echo -e "${GREEN}✓ File client_config.json trovato${NC}"
    
    # Mostra IP configurato
    CONFIGURED_IP=$(grep -o '"DefaultServerIp": "[^"]*"' "$CLIENT_CONFIG" | cut -d'"' -f4)
    echo "   IP attualmente configurato: $CONFIGURED_IP"
    
    if [ "$CONFIGURED_IP" != "$IP" ]; then
        echo -e "${YELLOW}   ⚠ L'IP configurato non corrisponde all'IP attuale!${NC}"
        echo ""
        read -p "   Vuoi aggiornarlo a $IP? (s/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[SsYy]$ ]]; then
            sed -i "s/\"DefaultServerIp\": \"[^\"]*\"/\"DefaultServerIp\": \"$IP\"/" "$CLIENT_CONFIG"
            echo -e "${GREEN}   ✓ IP aggiornato!${NC}"
        fi
    else
        echo -e "${GREEN}   ✓ IP già configurato correttamente${NC}"
    fi
else
    echo -e "${RED}✗ File client_config.json non trovato${NC}"
    echo "   Hai eseguito ./build_windows.sh?"
fi

echo ""
echo -e "${BLUE}[5/5]${NC} Riepilogo e istruzioni..."

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ PREPARAZIONE COMPLETATA${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📋 ISTRUZIONI PER IL TEST:${NC}"
echo ""
echo "SUL PC LINUX (questo computer):"
echo "  1. Se non è già avviato:"
echo "     cd Server && sudo ./start_server.sh"
echo ""
echo "SUL PC WINDOWS:"
echo "  1. Copia la cartella: build_windows/Client/"
echo "  2. Apri client_config.json con Notepad"
echo "  3. Verifica che 'DefaultServerIp' sia: $IP"
echo "  4. Salva e chiudi"
echo "  5. Doppio click su start_client.bat"
echo ""
echo "TEST DI CONNETTIVITÀ (da Windows CMD):"
echo "  ping $IP"
echo "  (deve rispondere!)"
echo ""
echo "TEST COMPLETO:"
echo "  • Nel client Windows inserisci nome e messaggio"
echo "  • Clicca 'Invia Richiesta'"
echo "  • La richiesta deve apparire sul server Linux!"
echo ""
echo "LOG:"
echo "  • Server: Server/server_log.txt"
echo "  • Client: Client/client_log.txt (sul PC Windows)"
echo ""
echo "═══════════════════════════════════════════════════════════"
