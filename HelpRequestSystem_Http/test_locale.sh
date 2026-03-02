#!/bin/bash

echo "🧪 TEST VELOCE - Sistema Help Request (localhost)"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Questo script testa il sistema in locale con 127.0.0.1"
echo ""

# Controlla se i progetti compilano
echo -e "${YELLOW}[1/4]${NC} Verifica compilazione..."
cd /home/king_monster_/Scrivania/HelpRequestSystem/Server
dotnet build > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Server compila${NC}"
else
    echo -e "${RED}✗ Errore compilazione Server${NC}"
    exit 1
fi

cd /home/king_monster_/Scrivania/HelpRequestSystem/Client
dotnet build > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Client compila${NC}"
else
    echo -e "${RED}✗ Errore compilazione Client${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[2/4]${NC} Verifica file di configurazione..."

# Verifica config server
if [ -f "/home/king_monster_/Scrivania/HelpRequestSystem/Server/server_config.json" ]; then
    echo -e "${GREEN}✓ server_config.json presente${NC}"
else
    echo -e "${YELLOW}⚠ server_config.json verrà creato al primo avvio${NC}"
fi

# Verifica config client
if [ -f "/home/king_monster_/Scrivania/HelpRequestSystem/Client/client_config.json" ]; then
    CLIENT_IP=$(grep -o '"DefaultServerIp": "[^"]*"' /home/king_monster_/Scrivania/HelpRequestSystem/Client/client_config.json | cut -d'"' -f4)
    echo -e "${GREEN}✓ client_config.json presente${NC}"
    echo -e "   IP server configurato: ${CLIENT_IP}"
    
    if [ "$CLIENT_IP" != "127.0.0.1" ]; then
        echo -e "${YELLOW}   ⚠ Suggerimento: Cambia IP a 127.0.0.1 per test locale${NC}"
    fi
else
    echo -e "${YELLOW}⚠ client_config.json verrà creato al primo avvio${NC}"
fi

echo ""
echo -e "${YELLOW}[3/4]${NC} Controlla log precedenti..."

cd /home/king_monster_/Scrivania/HelpRequestSystem/Server
if [ -f "server_log.txt" ]; then
    LAST_ERROR=$(grep -i "ERRORE" server_log.txt | tail -1)
    if [ ! -z "$LAST_ERROR" ]; then
        echo -e "${YELLOW}⚠ Ultimo errore server:${NC}"
        echo "   $LAST_ERROR"
    else
        echo -e "${GREEN}✓ Nessun errore nel log del server${NC}"
    fi
else
    echo -e "   Nessun log precedente"
fi

cd /home/king_monster_/Scrivania/HelpRequestSystem/Client
if [ -f "client_log.txt" ]; then
    LAST_ERROR=$(grep -i "ERRORE" client_log.txt | tail -1)
    if [ ! -z "$LAST_ERROR" ]; then
        echo -e "${YELLOW}⚠ Ultimo errore client:${NC}"
        echo "   $LAST_ERROR"
    else
        echo -e "${GREEN}✓ Nessun errore nel log del client${NC}"
    fi
else
    echo -e "   Nessun log precedente"
fi

echo ""
echo -e "${YELLOW}[4/4]${NC} Sistema pronto!"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ TUTTO OK! Sistema pronto per il test${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📋 PROSSIMI PASSI:"
echo ""
echo "1️⃣  AVVIA IL SERVER (in questo terminale):"
echo "   cd /home/king_monster_/Scrivania/HelpRequestSystem/Server"
echo "   sudo dotnet run"
echo ""
echo "2️⃣  AVVIA IL CLIENT (in un altro terminale):"
echo "   cd /home/king_monster_/Scrivania/HelpRequestSystem/Client"
echo "   dotnet run"
echo ""
echo "3️⃣  NEL CLIENT:"
echo "   • IP del Master: 127.0.0.1"
echo "   • Tuo nome: (inserisci il tuo nome)"
echo "   • Messaggio: Test di connessione"
echo "   • Clicca: 'Invia Richiesta'"
echo ""
echo "4️⃣  VERIFICA:"
echo "   • Client: Dovresti vedere 'Richiesta inviata correttamente!'"
echo "   • Server: La richiesta dovrebbe apparire nella lista"
echo ""
echo "📄 CONTROLLA I LOG:"
echo "   Server: tail -f /home/king_monster_/Scrivania/HelpRequestSystem/Server/server_log.txt"
echo "   Client: tail -f /home/king_monster_/Scrivania/HelpRequestSystem/Client/client_log.txt"
echo ""
echo "═══════════════════════════════════════════════════════════"
