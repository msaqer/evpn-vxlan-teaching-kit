**Commands:**

ip route

ping <dest>

traceroute <dest>

vtysh -c "show evpn vni"

vtysh -c "show evpn mac"

vtysh -c "show bgp l2vpn evpn summary"

# run commands inside a node (containerlab)
docker exec -it <node> vtysh -c "show bgp l2vpn evpn summary"

# or use the clab alias for exec:
clab exec -t labs/lab2_vxlan_evpn/topology.clab.yaml --cmd "vtysh -c 'show evpn vni'"

