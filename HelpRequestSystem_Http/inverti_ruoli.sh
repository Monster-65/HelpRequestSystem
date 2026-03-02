#!/bin/bash

echo "🔄 INVERSIONE RUOLI - Client Linux → Server Windows"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Questa configurazione usa:${NC}"
echo "  • Server: PC Windows (LAN)"
echo "  • Client: PC Linux (WiFi) - questo computer"
echo ""

# Chiedi l'IP del server Windows
echo -e "${YELLOW}📋 Sul PC Windows:${NC}"
echo "   1. Apri CMD"
echo "   2. Digita: ipconfig"
echo "   3. Cerca 'Indirizzo IPv4' della scheda LAN"
echo ""

read -p "Inserisci l'IP del server Windows: " WINDOWS_IP

if [ -z "$WINDOWS_IP" ]; then
    echo -e "${RED}✗ IP non inserito${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[1/3]${NC} Verifica connettività..."

# Ping al server Windows
echo "Ping a $WINDOWS_IP..."
ping -c 3 "$WINDOWS_IP" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Server Windows raggiungibile!${NC}"
else
    echo -e "${RED}✗ Impossibile raggiungere $WINDOWS_IP${NC}"
    echo "   Verifica che:"
    echo "   • I PC siano sulla stessa rete"
    echo "   • Il PC Windows sia acceso"
    echo "   • L'IP sia corretto"
    exit 1
fi

echo ""
echo -e "${BLUE}[2/3]${NC} Configurazione client Linux..."

# Modifica client_config.json
CLIENT_CONFIG="/home/king_monster_/Scrivania/HelpRequestSystem/Client/client_config.json"

if [ -f "$CLIENT_CONFIG" ]; then
    # Backup del file originale
    cp "$CLIENT_CONFIG" "${CLIENT_CONFIG}.backup"
    
    # Aggiorna l'IP
    sed -i "s/\"DefaultServerIp\": \"[^\"]*\"/\"DefaultServerIp\": \"$WINDOWS_IP\"/" "$CLIENT_CONFIG"
    
    echo -e "${GREEN}✓ client_config.json aggiornato${NC}"
    echo "   DefaultServerIp: $WINDOWS_IP"
    echo "   (Backup salvato in client_config.json.backup)"
else
    echo -e "${RED}✗ File client_config.json non trovato${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[3/3]${NC} Istruzioni finali..."

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ CONFIGURAZIONE COMPLETATA${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📋 PROSSIMI PASSI:${NC}"
echo ""
echo "SUL PC WINDOWS (Server - LAN):"
echo "  1. Copia la cartella: build_windows/Server/"
echo "  2. Doppio click su start_server.bat"
echo "  3. Consenti Windows Firewall (popup)"
echo "  4. Verifica che dica 'Server in ascolto...'"
echo ""
echo "SUL PC LINUX (Client - WiFi - questo computer):"
echo "  1. Esegui:"
echo "     cd Client"
echo "     ./start_client.sh"
echo "  2. Nell'interfaccia:"
echo "     • IP del Master: $WINDOWS_IP (già impostato)"
echo "     • Tuo nome: (il tuo nome)"
echo "     • Messaggio: Test Windows Server"
echo "     • Clicca 'Invia Richiesta'"
echo ""
echo "VERIFICA:"
echo "  • Client Linux: Dovrebbe dire 'Richiesta inviata correttamente!'"
echo "  • Server Windows: La richiesta dovrebbe apparire nella lista!"
echo ""
echo "LOG:"
echo "  • Server: Server/server_log.txt (sul PC Windows)"
echo "  • Client: Client/client_log.txt (questo PC)"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}💡 Suggerimento:${NC}"
echo "   Per tornare alla configurazione precedente:"
echo "   cp Client/client_config.json.backup Client/client_config.json"
echo ""
