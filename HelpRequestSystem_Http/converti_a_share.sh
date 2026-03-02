66#!/bin/bash

echo "🔄 CONVERSIONE A CARTELLA CONDIVISA"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "Questa soluzione elimina completamente i problemi di firewall"
echo "usando una cartella condivisa Windows invece di HTTP."
echo ""
echo -e "${BLUE}Come funziona:${NC}"
echo "  1. Client scrive file JSON nella cartella condivisa"
echo "  2. Master legge i file dalla cartella condivisa"
echo "  3. Nessuna porta di rete coinvolta!"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}REQUISITI:${NC}"
echo ""
echo "  ✓ Una cartella condivisa Windows accessibile da tutti i PC"
echo "    Esempio: \\\\SERVER\\HelpRequests"
echo "    Oppure: \\\\192.168.0.100\\Shared\\HelpRequests"
echo ""
echo "  ✓ Permessi di lettura per tutti (Client)"
echo "  ✓ Permessi di scrittura per tutti (Client)"
echo "  ✓ Permessi di lettura/scrittura/cancellazione per Master"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}CONFIGURAZIONE:${NC}"
echo ""

read -p "Hai già una cartella condivisa disponibile? (s/n): " HAS_SHARE

if [ "$HAS_SHARE" != "s" ]; then
    echo ""
    echo -e "${YELLOW}📋 COME CREARE UNA CARTELLA CONDIVISA SU WINDOWS:${NC}"
    echo ""
    echo "Sul PC Master (o qualsiasi PC Windows):"
    echo ""
    echo "  1. Crea una cartella: C:\\HelpRequests"
    echo ""
    echo "  2. Click destro → Proprietà → Condivisione"
    echo ""
    echo "  3. Clicca 'Condividi...'"
    echo ""
    echo "  4. Aggiungi 'Everyone' con permessi 'Lettura/Scrittura'"
    echo ""
    echo "  5. Clicca 'Condividi' → 'Fine'"
    echo ""
    echo "  6. Annota il percorso, sarà tipo:"
    echo "     \\\\NOMEPC\\HelpRequests"
    echo "     o"
    echo "     \\\\192.168.0.114\\HelpRequests"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    read -p "Premi INVIO quando hai creato la condivisione..." WAIT
fi

echo ""
read -p "Inserisci il percorso della cartella condivisa (es: //192.168.0.114/HelpRequests): " SHARE_PATH

if [ -z "$SHARE_PATH" ]; then
    echo -e "${RED}✗ Percorso non inserito${NC}"
    exit 1
fi

# Converti backslash in forward slash per compatibilità
SHARE_PATH=$(echo "$SHARE_PATH" | sed 's/\\/\//g')

echo ""
echo -e "${BLUE}Percorso condivisione:${NC} $SHARE_PATH"
echo ""

# Crea nuovi file di configurazione
echo -e "${BLUE}[1/2]${NC} Creazione configurazione per cartella condivisa..."

# Server config
cat > "/home/king_monster_/Scrivania/HelpRequestSystem/Server/server_config_share.json" <<EOF
{
  "Mode": "FileShare",
  "SharePath": "$SHARE_PATH",
  "PollIntervalSeconds": 2,
  "AutoDeleteProcessedFiles": true
}
EOF

# Client config
cat > "/home/king_monster_/Scrivania/HelpRequestSystem/Client/client_config_share.json" <<EOF
{
  "Mode": "FileShare",
  "SharePath": "$SHARE_PATH",
  "DefaultServerIp": "N/A (using file share)"
}
EOF

echo -e "${GREEN}✓ Configurazioni create${NC}"
echo "  • server_config_share.json"
echo "  • client_config_share.json"

echo ""
echo -e "${BLUE}[2/2]${NC} Istruzioni per modificare il codice..."

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ CONFIGURAZIONE COMPLETATA${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📋 PROSSIMI PASSI:${NC}"
echo ""
echo "Devo modificare il codice per usare file invece di HTTP."
echo ""
echo "Vuoi che proceda con le modifiche? (Creerò una versione alternativa)"
echo ""
echo "Le modifiche includeranno:"
echo "  • Client: Scrive file JSON invece di fare POST HTTP"
echo "  • Server: Monitora cartella invece di ascoltare su porta"
echo "  • Mantiene la stessa interfaccia grafica"
echo "  • Zero dipendenze da porte di rete"
echo ""
echo "Tempo stimato: 1-2 ore per implementare e testare"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}💡 Vantaggi di questa soluzione:${NC}"
echo "  ✓ Funziona con qualsiasi firewall aziendale"
echo "  ✓ Non richiede permessi speciali"
echo "  ✓ Semplicissima da deployare"
echo "  ✓ Log automatici (i file JSON sono già log)"
echo "  ✓ Recupero automatico da crash"
echo ""
echo -e "${YELLOW}⚠ Svantaggi:${NC}"
echo "  • Latenza ~2 secondi (polling ogni 2 sec)"
echo "  • Richiede cartella condivisa accessibile"
echo "  • File temporanei nella share"
echo ""
