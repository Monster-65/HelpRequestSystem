#!/bin/bash

SERVER_IP="192.168.0.114"
SERVER_PORT="7777"

echo "🔥 TEST CONNESSIONE DOPO CONFIGURAZIONE FIREWALL"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Server:${NC} $SERVER_IP:$SERVER_PORT"
echo ""

# Test 1: Telnet sulla porta
echo -e "${BLUE}[1/2]${NC} Test apertura porta 7777..."

# Installa telnet se necessario
if ! command -v telnet &> /dev/null; then
    echo "Installazione telnet..."
    sudo apt-get install -y telnet > /dev/null 2>&1
fi

# Test con timeout
timeout 3 bash -c "echo '' | telnet $SERVER_IP $SERVER_PORT 2>&1" | grep -q "Connected"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PORTA APERTA!${NC} Il firewall ora consente le connessioni"
else
    echo -e "${RED}✗ Porta ancora chiusa${NC}"
    echo ""
    echo "VERIFICA SUL PC WINDOWS:"
    echo "  1. Hai eseguito il comando firewall come Amministratore?"
    echo "  2. Hai visto 'Ok.' come risposta?"
    echo "  3. Prova a riavviare il server Windows"
    echo ""
    exit 1
fi

echo ""

# Test 2: HTTP GET (dovrebbe dare errore 405 ma conferma che risponde)
echo -e "${BLUE}[2/2]${NC} Test risposta HTTP..."

# Installa wget se necessario
if ! command -v wget &> /dev/null; then
    echo "Installazione wget..."
    sudo apt-get install -y wget > /dev/null 2>&1
fi

HTTP_CODE=$(wget --spider --server-response "http://$SERVER_IP:$SERVER_PORT/api/helprequest/" 2>&1 | grep "HTTP/" | tail -1 | awk '{print $2}')

if [ "$HTTP_CODE" = "405" ] || [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ SERVER RISPONDE!${NC} (HTTP $HTTP_CODE)"
    echo "  Il server è raggiungibile dalla rete!"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ FIREWALL CONFIGURATO CORRETTAMENTE!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📋 PROSSIMO PASSO:${NC}"
    echo "   1. Riavvia il client su questo PC:"
    echo "      cd Client && ./start_client.sh"
    echo ""
    echo "   2. Invia una richiesta di test:"
    echo "      • IP Server: 192.168.0.114 (già impostato)"
    echo "      • Nome: Gabry"
    echo "      • Messaggio: Test dopo firewall"
    echo ""
    echo "   3. Controlla che sul server Windows appaia la richiesta!"
    echo ""
else
    echo -e "${YELLOW}⚠ Risposta HTTP: $HTTP_CODE${NC}"
    echo "  Il server risponde ma con un codice inatteso"
fi

echo ""
