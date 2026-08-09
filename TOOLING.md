# Tooling-Inventar

Quelle: überprüfte Installation des VIRIDIS Dev Bot am 2026-08-09 (Ubuntu 24.04.4 LTS). Das Host-System hat 482 installierte Debian-Pakete; Systembibliotheken, OpenClaw-spezifische Laufzeitpakete und reine Betriebsabhängigkeiten wurden nicht ungeprüft in das Image kopiert. Stattdessen enthält das Image die für Entwicklungsaufträge sinnvolle, wartbare Teilmenge unten.

## Auf dem Host festgestellte Entwicklungsbefehle

| Host-Befehl | Aufnahme im Image | Bereitstellung |
| --- | --- | --- |
| bash | ja | `bash` |
| node, npm, corepack, pnpm | ja | Node.js 22 + Corepack; `pnpm` wird bei erstem Einsatz über Corepack aktiviert |
| git | ja | `git` |
| docker | ja | `docker-ce-cli`; einen Daemon liefert der Container nicht |
| make, gcc, g++ | ja | `build-essential` und `make` |
| python3, pip3 | ja | `python3`, `python3-pip`, `python3-venv` |
| jq, yq | ja | `jq`; aktuelles Go-yq-Binary |
| curl, ssh, rsync, gpg, openssl | ja | jeweilige Ubuntu-Pakete |
| kubectl, helm, terraform | ja | versionsfixierte Upstream-Binaries |
| ffmpeg | ja | `ffmpeg` |
| wget | ja | `wget` |

Auf dem Dev Bot nicht als ausführbarer Befehl festgestellt und daher nicht pauschal aufgenommen: `git-lfs`, `gh`, `uv`, `poetry`, `ansible`, Java, Go, Rust, PHP, Ruby, SQLite-, PostgreSQL-, MySQL- und Redis-Clients. Falls ein konkretes Projekt diese benötigt, sollen sie versionsfixiert ergänzt werden statt die Basis unnötig aufzublähen.

## Debian-Pakete im Image

| Paket | Zweck |
| --- | --- |
| `bash-completion`, `less` | interaktive Shell |
| `build-essential`, `make` | C/C++- und native Node/Python-Builds |
| `ca-certificates`, `curl`, `wget` | HTTPS und Downloads |
| `ffmpeg` | Medienwerkzeuge |
| `git`, `openssh-client`, `rsync` | Source Control und Übertragung |
| `gnupg`, `openssl` | Signaturen und kryptografische Werkzeuge |
| `iputils-ping` | einfache Netzwerkdiagnose |
| `jq` | JSON-Verarbeitung |
| `python3`, `python3-pip`, `python3-venv` | Python-Entwicklung |
| `shellcheck` | Shell-Linting |
| `sudo` | gezielte administrative Befehle im vertrauenswürdigen Runner |
| `unzip`, `xz-utils`, `zip` | Archive und Upstream-Tool-Installation |
| `docker-ce-cli` | Docker-Client für einen gemounteten Socket |
| `nodejs` (NodeSource) | Node.js 22 LTS, npm, Corepack |

Zusätzlich werden die versionsfixierten Binärdateien `kubectl`, `helm`, `terraform` und `yq` nach `/usr/local/bin` installiert.

## Nicht kopierte Host-Pakete

Der Host enthält u. a. OpenClaw-, Browser-, Audio-, KI- und Kubernetes-Runtime-Abhängigkeiten. Diese sind keine allgemeingültigen Entwicklungswerkzeuge, vergrößern die Angriffsfläche und werden deshalb nicht in das Image übernommen. Die vollständige Host-Liste kann bei Bedarf reproduzierbar mit folgendem Befehl erhoben werden:

```bash
dpkg-query -W -f='${binary:Package}\t${Version}\n' | LC_ALL=C sort
```

Dies ist bewusst eine Momentaufnahme: Paketversionen des Host-Betriebssystems sind nicht die Versionsquelle für das Container-Image. Reproduzierbarkeit wird über die im Dockerfile gesetzten Tool-Versionen und die Ubuntu-Basis erreicht.
