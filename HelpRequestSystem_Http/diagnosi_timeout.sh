#!/bin/bash

echo "🔍 DIAGNOSI TIMEOUT - Server Windows non risponde"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVER_IP="192.168.0.114"
SERVER_PORT="7777"

echo -e "${BLUE}Server di destinazione:${NC} $SERVER_IP:$SERVER_PORT"
echo ""

# Test 1: Ping
echo -e "${BLUE}[1/5]${NC} Test connettività di base (ping)..."
ping -c 3 "$SERVER_IP" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Ping OK${NC} - Il PC Windows è raggiungibile"
else
    echo -e "${RED}✗ Ping FALLITO${NC} - Il PC Windows non risponde al ping"
    echo ""
    echo "POSSIBILI CAUSE:"
    echo "  • Il PC Windows non è acceso"
    echo "  • Non siete sulla stessa rete"
    echo "  • L'IP è cambiato"
    echo "  • Windows Firewall blocca il ping (non grave)"
    echo ""
    read -p "Vuoi continuare comunque? (s/n): " CONTINUE
    if [ "$CONTINUE" != "s" ]; then
        exit 1
    fi
fi

echo ""

# Test 2: Verifica porta aperta
echo -e "${BLUE}[2/5]${NC} Test porta TCP $SERVER_PORT (telnet)..."

# Controlla se telnet è installato
if ! command -v telnet &> /dev/null; then
    echo -e "${YELLOW}⚠ telnet non installato${NC}"
    echo "Installazione telnet..."
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y telnet > /dev/null 2>&1
fi

# Test con timeout di 3 secondi
timeout 3 bash -c "echo '' | telnet $SERVER_IP $SERVER_PORT" 2>&1 | grep -q "Connected"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Porta $SERVER_PORT APERTA${NC} - Il server sta ascoltando!"
else
    echo -e "${RED}✗ Porta $SERVER_PORT CHIUSA o FILTRATA${NC}"
    echo ""
    echo "CAUSE COMUNI:"
    echo "  1. Il server Windows NON è avviato"
    echo "  2. Windows Firewall blocca la porta 7777"
    echo "  3. Il server è in ascolto su un'altra porta"
    echo ""
fi

echo ""

# Test 3: Verifica HTTP con curl
echo -e "${BLUE}[3/5]${NC} Test HTTP endpoint (curl)..."

HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "http://$SERVER_IP:$SERVER_PORT/api/helprequest/" 2>&1)

if [ "$HTTP_RESPONSE" = "405" ] || [ "$HTTP_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ Server HTTP risponde${NC} (Status: $HTTP_RESPONSE)"
    echo "  Il server è operativo!"
elif [ "$HTTP_RESPONSE" = "000" ]; then
    echo -e "${RED}✗ Nessuna risposta HTTP${NC}"
    echo "  Il server non risponde o la porta è bloccata"
else
    echo -e "${YELLOW}⚠ Risposta HTTP inattesa: $HTTP_RESPONSE${NC}"
fi

echo ""

# Test 4: Verifica configurazione client
echo -e "${BLUE}[4/5]${NC} Verifica configurazione client..."

CLIENT_CONFIG="/home/king_monster_/Scrivania/HelpRequestSystem/Client/client_config.json"

if [ -f "$CLIENT_CONFIG" ]; then
    CONFIG_IP=$(grep "DefaultServerIp" "$CLIENT_CONFIG" | cut -d'"' -f4)
    CONFIG_PORT=$(grep "ServerPort" "$CLIENT_CONFIG" | cut -d'"' -f4)
    
    echo "  DefaultServerIp: $CONFIG_IP"
    echo "  ServerPort: $CONFIG_PORT"
    
    if [ "$CONFIG_IP" = "$SERVER_IP" ]; then
        echo -e "${GREEN}✓ IP configurato correttamente${NC}"
    else
        echo -e "${RED}✗ IP non corrisponde!${NC}"
        echo "  Configurato: $CONFIG_IP"
        echo "  Atteso: $SERVER_IP"
    fi
    
    if [ "$CONFIG_PORT" = "$SERVER_PORT" ]; then
        echo -e "${GREEN}✓ Porta configurata correttamente${NC}"
    else
        echo -e "${RED}✗ Porta non corrisponde!${NC}"
    fi
else
    echo -e "${RED}✗ File di configurazione non trovato${NC}"
fi

echo ""

# Test 5: Verifica permessi log
echo -e "${BLUE}[5/5]${NC} Verifica permessi file di log..."

CLIENT_LOG="/home/king_monster_/Scrivania/HelpRequestSystem/Client/client_log.txt"

if [ -f "$CLIENT_LOG" ]; then
    if [ -w "$CLIENT_LOG" ]; then
        echo -e "${GREEN}✓ client_log.txt scrivibile${NC}"
    else
        echo -e "${RED}✗ client_log.txt NON scrivibile${NC}"
        echo "  Risoluzione: sudo chmod 666 $CLIENT_LOG"
    fi
else
    # File non esiste, testa se possiamo crearlo
    touch "$CLIENT_LOG" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Possibile creare client_log.txt${NC}"
    else
        echo -e "${RED}✗ Impossibile creare client_log.txt${NC}"
        echo "  La directory potrebbe non essere scrivibile"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}📋 RACCOMANDAZIONI${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "SUL PC WINDOWS (192.168.0.114):"
echo ""
echo "1️⃣  VERIFICA CHE IL SERVER SIA AVVIATO"
echo "    • Controlla che start_server.bat sia in esecuzione"
echo "    • Cerca la finestra del server"
echo "    • Dovrebbe dire: 'Server in ascolto su http://+:7777/api/helprequest/'"
echo ""
echo "2️⃣  CONFIGURA WINDOWS FIREWALL"
echo "    Opzione A - Facile (se hai privilegi admin):"
echo "      • Pannello di Controllo → Windows Defender Firewall"
echo "      • Consenti app o funzionalità → Modifica impostazioni"
echo "      • Cerca Server.exe → Spunta 'Privata' → OK"
echo ""
echo "    Opzione B - Da PowerShell (come Administrator):"
echo "      New-NetFirewallRule -DisplayName 'HelpRequest Server' \\"
echo "        -Direction Inbound -Protocol TCP -LocalPort 7777 \\"
echo "        -Action Allow -Profile Private"
echo ""
echo "    Opzione C - Da CMD (come Administrator):"
echo "      netsh advfirewall firewall add rule name=\"HelpRequest Server\" \\"
echo "        dir=in action=allow protocol=TCP localport=7777"
echo ""
echo "3️⃣  VERIFICA L'IP DEL SERVER WINDOWS"
echo "    • Apri CMD sul PC Windows"
echo "    • Digita: ipconfig"
echo "    • Verifica che l'IP sia davvero 192.168.0.114"
echo "    • Se è cambiato, ri-esegui: ./inverti_ruoli.sh"
echo ""
echo "4️⃣  TEST MANUALE (dal PC Windows)"
echo "    • Apri browser su Windows"
echo "    • Vai su: http://localhost:7777/api/helprequest/"
echo "    • Dovresti vedere errore 405 (normale, serve POST)"
echo "    • Se vedi errore connessione → server non avviato!"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}💡 Dopo aver sistemato sul PC Windows:${NC}"
echo "   1. Riavvia il client su questo PC Linux"
echo "   2. Invia una richiesta di test"
echo "   3. Controlla server_log.txt su Windows"
echo ""
