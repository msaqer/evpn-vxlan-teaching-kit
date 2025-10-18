# EVPN-VXLAN Teaching Kit helpers

.PHONY: lab1-up lab1-down lab2-up lab2-down evpn-smoke

lab1-up:
	sudo clab deploy -t labs/lab1_underlay/topology.clab.yaml

lab1-down:
	sudo clab destroy -t labs/lab1_underlay/topology.clab.yaml

lab2-up:
	sudo clab deploy -t labs/lab2_vxlan_evpn/topology.clab.yaml

lab2-down:
	sudo clab destroy -t labs/lab2_vxlan_evpn/topology.clab.yaml

# Quick verification for Lab 2 (FRR/vtysh)
evpn-smoke:
	clab exec -t labs/lab2_vxlan_evpn/topology.clab.yaml --cmd 'vtysh -c "show bgp l2vpn evpn summary"'
	clab exec -t labs/lab2_vxlan_evpn/topology.clab.yaml --cmd 'vtysh -c "show evpn vni"'
	clab exec -t labs/lab2_vxlan_evpn/topology.clab.yaml --cmd 'vtysh -c "show evpn mac"'
	@echo "✅ EVPN smoke test ran. Review outputs above."
