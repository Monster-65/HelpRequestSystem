#!/bin/bash
# Script per trovare rapidamente l'IP locale del server

echo ""
echo "🌐 IP DEL SERVER:"
echo "════════════════════════════════════════"
echo ""

# Metodo 1: hostname
IP1=$(hostname -I | awk '{print $1}')
if [ ! -z "$IP1" ]; then
    echo "   IP: $IP1"
    echo ""
    echo "📋 Inserisci questo IP nel client!"
    echo ""
fi

# Mostra anche tutte le interfacce
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tutte le interfacce di rete:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "   → " $2}' | cut -d'/' -f1

echo ""
echo "════════════════════════════════════════"
echo "Usa il primo IP per il client!"
echo ""
