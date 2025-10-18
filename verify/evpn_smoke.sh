#!/usr/bin/env bash
set -euo pipefail

TOPO="labs/lab2_vxlan_evpn/topology.clab.yaml"

clab exec -t "$TOPO" --cmd 'vtysh -c "show bgp l2vpn evpn summary"'
clab exec -t "$TOPO" --cmd 'vtysh -c "show evpn vni"'
clab exec -t "$TOPO" --cmd 'vtysh -c "show evpn mac"'

echo "✅ EVPN smoke test ran. Review outputs above."
