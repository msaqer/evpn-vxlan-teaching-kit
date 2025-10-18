# EVPN-VXLAN Teaching Kit — v0.1 Starter Design

**Goal.** Make modern **datacenter** fabrics teachable to *early undergraduates* using free, reproducible emulation on ordinary campus PCs. This repo provides a minimal, vendor‑neutral starter design: **underlay vs. overlay basics**, **VXLAN** overlay, **BGP EVPN** control plane, and **essential operations** (visibility, failure domains, simple ECMP paths).


**Purpose.** A small, vendor-neutral teaching kit for *early undergraduates* that runs on standard campus PCs. This starter will be co-developed with ND faculty/industry after the conference. It aligns with **K–20 STEM education** and **workforce development** as ND expands AI/datacenter activity (e.g., CoreWeave capacity within Applied Digital sites at Ellendale and Harwood).

---

## Quick start

**Requirements (instructor machine or lab PCs):**
- Linux **or** Windows 11 with **WSL2** (Windows Subsystem for Linux, https://learn.microsoft.com/en-us/windows/wsl/about) 
- Docker/Podman (8–16 GB RAM recommended)  
- **containerlab** (primary runtime for these labs): One of: [containerlab](https://containerlab.dev) **or** [GNS3](https://www.gns3.com). **Note:** > GNS3 project: planned for v0.2. Containerlab is the reference runtime in v0.1.
- Images (pinned for reproducibility):  
  - `alpine:3.19` (hosts / simple routers)  
  - `frrouting/frr:v10.1` (FRR routers)

**Install containerlab (Linux):**
```bash
curl -sL https://get.containerlab.srlinux.dev | **sudo** bash
```
**Pre‑pull pinned images (faster workshops):**
```bash
docker pull alpine:3.19
docker pull frrouting/frr:v10.1
```


---

## How to run (fastest path)

```bash
# 1) install containerlab (Linux)
curl -sL https://get.containerlab.srlinux.dev | **sudo** bash

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
## Windows 11 (WSL2) setup

The labs run great on a stock Windows laptop using WSL2 + Docker.

**One‑time in PowerShell (as Administrator):**
```powershell
wsl --install -d Ubuntu
```

**Then inside the Ubuntu (WSL) terminal:**
```bash
# Base tools + Docker
sudo apt update && sudo apt install -y curl ca-certificates git docker.io

# Enable Docker in WSL
sudo systemctl enable --now docker || true
sudo usermod -aG docker $USER

# Install containerlab (needs root)
curl -sL https://get.containerlab.srlinux.dev | **sudo** bash

# Close and reopen your WSL terminal so the docker group applies, then:
docker ps   # should work without sudo
```

> If `systemctl` is unavailable in your WSL image, you can launch dockerd manually or use Docker Desktop with the WSL2 backend enabled. Either works with containerlab.

---
## Labs

### Lab 1 — Underlay & Overlay Basics (90–120 min)
Focus: IP underlay, loopback addressing, basic reachability/visibility, and a minimal overlay baseline.

**What you should see/verify (examples):**
- Underlay interfaces up, loopbacks reachable
- Basic L3 reachability and traceroute visibility between leaves via the spine
- Clean separation between underlay IP and overlay plans

**Outcome:** Understand physical **underlay** vs. virtual **overlay**; trace packet paths.
- **Tasks:** build a 3-router IP underlay; verify reachability; add a simple overlay segment.
- **Verify:** ip route, ping, traceroute.
- **Deliverable:** one-page worksheet (topology, commands, answers).


**Deploy (containerlab example):**
```bash
sudo clab deploy -t labs/lab1_underlay/topology.clab.yaml
```

**Destroy (explicit path to avoid placeholder confusion) when done:**
```bash
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

### Lab 2 — VXLAN + BGP EVPN (120–150 min)
Focus: VXLAN data plane + EVPN control plane (Type‑2 MAC/IP advertisements, VNI checks, basic ECMP discussion).

**You’re looking for:**
- Established EVPN BGP sessions between leaves and spine
- VNIs present and in the expected state
- MAC and MAC‑IP entries learned/advertised via EVPN

**Outcome:** See how **VXLAN** tunnels Layer-2 over IP and how **BGP EVPN** advertises MAC/IP reachability.
- **Tasks:** bring up FRRouting; configure VNI/VTEPs; enable EVPN; connect two tenants.
- **Verify:** show evpn vni; show evpn mac; show bgp l2vpn evpn summary.
- **Deliverable:** short checklist + screenshots of verification commands.



**Deploy:**
```bash
sudo clab deploy -t labs/lab2_vxlan_evpn/topology.clab.yaml
```

**Destroy when done:**
```bash
sudo clab destroy -t labs/lab2_vxlan_evpn/topology.clab.yaml
```

**Verify:**
- `vtysh -c "show evpn vni"`
- `vtysh -c "show evpn mac"`
- `vtysh -c "show bgp l2vpn evpn summary"`


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


---

## Verification commands (FRR/vtysh) with exec shortcut:

Use `clab exec` to run **vtysh** across nodes (or add `-n <node>` to target a specific device). Run these after **Lab 2** is up:

```bash
clab exec -t labs/lab2_vxlan_evpn/topology.clab.yaml --cmd 'vtysh -c "show bgp l2vpn evpn summary"'
clab exec -t labs/lab2_vxlan_evpn/topology.clab.yaml --cmd 'vtysh -c "show evpn vni"'
clab exec -t labs/lab2_vxlan_evpn/topology.clab.yaml --cmd 'vtysh -c "show evpn mac"'
```

> **Instructor note:** configs can be templated; keep a single tenant/VNI for clarity.

---
## Optional Makefile helpers

For quicker demos, the repo includes a small `Makefile` with convenience targets:

```bash
make lab1-up      # bring up Lab 1
make lab1-down    # tear down Lab 1
make lab2-up      # bring up Lab 2
make lab2-down    # tear down Lab 2
make evpn-smoke   # quick verification for Lab 2 (BGP EVPN/VNIs/MACs)
```

---

## Assessment rubrics 

- **Configuration correctness (40%)**  
- **Troubleshooting & verification (40%)**  
- **Explanation/diagram clarity (20%)**

---

## Troubleshooting

- **Docker permission denied (WSL):** Reopen your WSL terminal after `usermod -aG docker $USER`. If needed, run `sudo -E dockerd &` to start the daemon in a pinch.  
- **Image pulls are slow on conference Wi‑Fi:** pre‑pull with the commands above or bring a local registry/cache.  
- **No EVPN routes:** check BGP neighbors (`show bgp summary`), VNI mapping, and that loopbacks are reachable in the underlay.  
- **Interface names differ on your host:** container runtimes may rename veths; rely on FRR “show” outputs, not host veth names.

---

## Glossary

- **Underlay/Overlay:** Physical IP network vs. virtual networks built on top.  
- **VXLAN:** Method to carry Layer-2 segments across an IP underlay.  
- **BGP EVPN:** Control plane that advertises MAC/IP info for VXLAN overlays.  
- **ECMP:** Using multiple equal-cost paths to spread traffic.

---

## Collaboration menu & roadmap

The poster invites ND partners to co‑develop ready‑to‑run classroom materials. Good first issues:

1) **Observability add‑on.** Add flows/taps + CLI to visualize underlay/overlay reachability (e.g., sFlow/pcap options, “show” command cookbook).  
2) **Failure‑injection mini‑lab.** Safe, purposeful failures (link down/VRF/VNI mis‑tie) with “observe → hypothesize → fix” steps.  
3) **Context pack (AI halls).** Short primer on cooling/power constraints for datacenter/AI rooms to ground networking trade‑offs. 


**Contribution workflow.** Fork → small PRs (<150 lines) → rubric/diagram updates.  
**Contact.** Muhammad Abusaqer — Minot State University — muhammad.abusaqer@minotstateu.edu

---
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
**License:** MIT
