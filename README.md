# EVPN-VXLAN Teaching Kit — v0.1 Starter Design

**Purpose.** A small, vendor-neutral teaching kit for *early undergraduates* that runs on standard campus PCs. This starter will be co-developed with ND faculty/industry after the conference. It aligns with **K–20 STEM education** and **workforce development** as ND expands AI/data-center activity (e.g., CoreWeave capacity within Applied Digital sites at Ellendale and Harwood).

---

## Quick start (prototype path)

**Requirements (instructor machine or lab PCs):**
- Linux or Windows with WSL2  
- Docker/Podman (8–16 GB RAM recommended per PC)  
- One of: [containerlab](https://containerlab.dev) **or** [GNS3](https://www.gns3.com)  
- Images (pinned for reproducibility):  
  - `alpine:3.19` (hosts / simple routers)  
  - `frrouting/frr:v10.1` (FRR routers)

**Install containerlab (Linux):**
```bash
curl -sL https://get.containerlab.srlinux.dev | bash
```

**Clone this kit:**
```bash
git clone https://github.com/msaqer/evpn-vxlan-teaching-kit
cd evpn-vxlan-teaching-kit
```

## Repo layout
```
evpn-vxlan-teaching-kit/
  README.md                  # quick start, glossary
  labs/
    lab1_underlay/          # topology, tasks, verify cmds
    lab2_vxlan_evpn/        # topology, tasks, verify cmds
  topologies/               # standalone demo(s)
  rubrics/                  # short grading checklists
  verify/                   # common verify commands
  LICENSE                   # MIT
```

---

## How to run (fastest path)

```bash
# 1) install containerlab (Linux)
curl -sL https://get.containerlab.srlinux.dev | bash

# 2) clone
git clone https://github.com/msaqer/evpn-vxlan-teaching-kit
cd evpn-vxlan-teaching-kit

# 3) Lab 1
sudo clab deploy -t labs/lab1_underlay/topology.clab.yaml

# 4) Lab 2
sudo clab deploy -t labs/lab2_vxlan_evpn/topology.clab.yaml

# 5) Clean up (destroy uses the same topology file you deployed)
sudo clab destroy -t <same-topology-file>
```

> **Tip:** Angle-bracket placeholders like `<same-topology-file>` are *examples*—replace with the actual path you used (e.g., `labs/lab1_underlay/topology.clab.yaml`). When writing commands in Markdown, put placeholders in code backticks so the brackets display correctly.

---

## Lab 1 — Underlay/Overlay Basics (90–120 min)

**Outcome:** Understand physical **underlay** vs. virtual **overlay**; trace packet paths.
- **Tasks:** build a 3-router IP underlay; verify reachability; add a simple overlay segment.
- **Verify:** ip route, ping, traceroute.
- **Deliverable:** one-page worksheet (topology, commands, answers).


**Run (containerlab example):**
```bash
sudo clab deploy -t labs/lab1_underlay/topology.clab.yaml
# when done
sudo clab destroy -t labs/lab1_underlay/topology.clab.yaml
```

**Verify:** `ip route`, `ping`, `traceroute`.  
**Deliverable:** One-page worksheet (topology, commands, answers).

**Topology (labs/lab1_underlay/topology.clab.yaml):**
```yaml
name: lab1-underlay
topology:
  nodes:
    r1: { kind: linux, image: alpine:3.19 }
    r2: { kind: linux, image: alpine:3.19 }
    r3: { kind: linux, image: alpine:3.19 }
  links:
    - endpoints: ["r1:eth1","r2:eth1"]
    - endpoints: ["r2:eth2","r3:eth1"]
```

> **Instructor note:** use simple static routes or `ip route add` for reachability; an “overlay” can be introduced by a veth pair bridging two host namespaces.  
> **Alpine tip:** inside Alpine hosts, install tools if missing: `apk add iputils traceroute`.

---

## Lab 2 — VXLAN + BGP EVPN (120–150 min)

**Outcome:** See how **VXLAN** tunnels Layer-2 over IP and how **BGP EVPN** advertises MAC/IP reachability.
- **Tasks:** bring up FRRouting; configure VNI/VTEPs; enable EVPN; connect two tenants.
- **Verify:** show evpn vni; show evpn mac; show bgp l2vpn evpn summary.
- **Deliverable:** short checklist + screenshots of verification commands.


**Run:**
```bash
sudo clab deploy -t labs/lab2_vxlan_evpn/topology.clab.yaml
# when done
sudo clab destroy -t labs/lab2_vxlan_evpn/topology.clab.yaml
```

**Verify:**
- `vtysh -c "show evpn vni"`
- `vtysh -c "show evpn mac"`
- `vtysh -c "show bgp l2vpn evpn summary"`

> **Exec shortcut:**  
> `clab exec -t labs/lab2_vxlan_evpn/topology.clab.yaml --cmd "vtysh -c 'show bgp l2vpn evpn summary'"`

**Topology (labs/lab2_vxlan_evpn/topology.clab.yaml):**
```yaml
name: lab2-evpn-vxlan
topology:
  nodes:
    leaf1: { kind: linux, image: frrouting/frr:v10.1 }
    leaf2: { kind: linux, image: frrouting/frr:v10.1 }
    spine:  { kind: linux, image: frrouting/frr:v10.1 }
    hostA:  { kind: linux, image: alpine:3.19 }
    hostB:  { kind: linux, image: alpine:3.19 }
  links:
    - endpoints: ["leaf1:eth1","spine:eth1"]
    - endpoints: ["leaf2:eth1","spine:eth2"]
    - endpoints: ["leaf1:eth2","hostA:eth1"]
    - endpoints: ["leaf2:eth2","hostB:eth1"]
```

**Config sketch (per leaf):**
- Create a VNI (e.g., 10010), set VTEP (loopback) as source, bind to a bridge.
- Enable BGP EVPN address family; advertise connected MAC/IP.

> **Instructor note:** configs can be templated; keep a single tenant/VNI for clarity.

---

## Assessment rubrics (short form)

- **Configuration correctness (40%)**  
- **Troubleshooting & verification (40%)**  
- **Explanation/diagram clarity (20%)**

---

## Glossary (plain English)

- **Underlay/Overlay:** Physical IP network vs. virtual networks built on top.  
- **VXLAN:** Method to carry Layer-2 segments across an IP underlay.  
- **BGP EVPN:** Control plane that advertises MAC/IP info for VXLAN overlays.  
- **ECMP:** Using multiple equal-cost paths to spread traffic.

---

## Collaboration menu (pick one small item)

1. **Observability add-on:** minimal counters/flow view for labs.  
2. **Failure injection:** flap a link; observe convergence.  
3. **Context pack:** 3–4 slides on cooling/power in AI halls relevant to ND sites.

**Contribution workflow.** Fork → small PRs (<150 lines) → rubric/diagram updates.  
**Contact.** Muhammad Abusaqer — Minot State University — muhammad.abusaqer@minotstateu.edu

---

**License:** MIT
