#!/bin/bash

echo "🗑️  GESTIONE CACHE NUGET"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NUGET_CACHE="$HOME/.nuget/packages"

# Funzione per formattare dimensioni
format_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

echo -e "${BLUE}[1/3]${NC} Stato cache NuGet..."
echo ""

if [ -d "$NUGET_CACHE" ]; then
    CACHE_SIZE=$(format_size "$NUGET_CACHE")
    echo -e "${GREEN}✓ Cache trovata${NC}"
    echo "  Percorso: $NUGET_CACHE"
    echo "  Dimensione: $CACHE_SIZE"
    echo ""
    
    # Cerca runtime Windows
    WIN_RUNTIME=$(find "$NUGET_CACHE" -type d -name "*runtime.win-x64*" 2>/dev/null | wc -l)
    if [ $WIN_RUNTIME -gt 0 ]; then
        echo -e "${GREEN}✓ Runtime Windows trovati: $WIN_RUNTIME pacchetti${NC}"
        echo "  Le prossime build saranno veloci!"
    else
        echo -e "${YELLOW}⚠ Runtime Windows non in cache${NC}"
        echo "  La prossima build scaricherà ~200MB"
    fi
else
    echo -e "${YELLOW}⚠ Cache NuGet non trovata${NC}"
    echo "  Verrà creata alla prima build"
fi

echo ""
echo -e "${BLUE}[2/3]${NC} Opzioni disponibili..."
echo ""
echo "  1) Pulisci cache (forza re-download)"
echo "  2) Pre-carica runtime Windows (per build veloce)"
echo "  3) Mostra dettagli cache"
echo "  4) Esci"
echo ""

read -p "Scegli un'opzione [1-4]: " CHOICE

echo ""
echo -e "${BLUE}[3/3]${NC} Esecuzione..."
echo ""

case $CHOICE in
    1)
        echo "Pulizia cache NuGet..."
        dotnet nuget locals all --clear
        echo -e "${GREEN}✓ Cache pulita${NC}"
        echo "  La prossima build scaricherà tutti i pacchetti"
        ;;
    2)
        echo "Pre-caricamento runtime Windows..."
        echo "  (Può richiedere 2-5 minuti)"
        echo ""
        
        # Pre-ripristino per entrambi i progetti
        cd "$(dirname "$0")"
        dotnet restore Client/Client.csproj -r win-x64 --force
        dotnet restore Server/Server.csproj -r win-x64 --force
        
        echo ""
        echo -e "${GREEN}✓ Runtime Windows scaricati${NC}"
        echo "  Le prossime build saranno veloci!"
        ;;
    3)
        echo "Dettagli cache NuGet:"
        echo ""
        dotnet nuget locals all --list
        echo ""
        
        if [ -d "$NUGET_CACHE" ]; then
            echo "Pacchetti più grandi:"
            du -sh "$NUGET_CACHE"/* 2>/dev/null | sort -hr | head -10
        fi
        ;;
    4)
        echo "Uscita."
        exit 0
        ;;
    *)
        echo -e "${RED}✗ Opzione non valida${NC}"
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ COMPLETATO${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
