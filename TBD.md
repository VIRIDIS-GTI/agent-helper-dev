# TBD — Agent Helper Dev Docker Image

## Verifizierte Umgebungsnotiz (2026-08-09)

Im aktuellen VIRIDIS-Dev-Bot-Pod ist die Docker-CLI vorhanden (`Docker 27.5.1`), aber `/var/run/docker.sock` fehlt und es läuft kein Docker-Daemon. Ein lokaler Build oder Socket-Integrationstest ist in diesem Pod deshalb nicht möglich. Die Test-Commands in der README sind für einen vertrauenswürdigen Docker-Runner vorbereitet.

## Offene Entscheidungen

1. **Image-Publishing und CI:** Soll GitHub Actions auf jeden Push nach `main` nach `ghcr.io/viridis-gti/agent-helper-dev` bauen und versionierte Tags (SHA, SemVer, `latest`) veröffentlichen? Empfehlung: ja; `latest` nur zusätzlich zu unveränderlichen SHA-Tags.
2. **Docker-Socket-Sicherheitsmodell:** Der Socket gibt effektiv Host-Root-Rechte. Soll die Nutzung nur durch einen dedizierten, kurzlebigen Runner erlaubt werden? Empfehlung: ja; kein Socket in normalen OpenClaw-/Paperclip-Workloads.
3. **Ausführender Benutzer:** Das Image startet als UID 1000 (`agent`). Für einen Socket mit abweichender Gruppen-ID ist `--group-add "$(stat -c %g /var/run/docker.sock)"` nötig. Alternative: bewusst `--user 0` nur im privilegierten Build-Runner. Empfehlung: Gruppen-ID zur Laufzeit hinzufügen, root vermeiden.
4. **Zusätzliche Sprach-Stacks:** Go, Rust, Java, PHP, Ruby, Datenbank-Clients, `gh`, `uv`, `poetry`, Ansible und Git LFS sind auf dem Dev Bot nicht standardmäßig als Befehl vorhanden. Sollen sie in eine zweite, größere Variante (`agent-helper-dev:full`) statt in das Basis-Image? Empfehlung: ja, um die Basis klein und patchbar zu halten.
5. **Versionspflege:** Node, kubectl, Helm, Terraform und yq sind als Dockerfile-ARGs fixiert. Soll Dependabot/Renovate diese Werte aktualisieren und dafür einen Smoke-Test ausführen? Empfehlung: ja.
6. **Tool-Download-Supply-Chain:** Die Upstream-Binaries werden über HTTPS geladen. Soll der Build zusätzlich SHA256-Prüfsummen prüfen? Empfehlung: ja, bevor das Image produktiv verwendet wird.
7. **Secret-Übergabe:** Soll ein standardisiertes Runner-Wrapper-Skript ausschließlich SSH-Agent-Sockets und kurzlebige Token einreichen? Empfehlung: ja; keine dauerhaften private Keys per Environment.

## Erledigt

- [x] Entwicklungs-Toolliste des Dev Bot geprüft und in `TOOLING.md` dokumentiert.
- [x] Dockerfile auf Ubuntu 24.04 aktualisiert; enthält Node, pnpm/Corepack, Git, Python, Build-Tools, Docker CLI, kubectl, Helm, Terraform, yq und ffmpeg.
- [x] README mit Volume-, Secret- und Docker-Socket-Sicherheitsmodell geschrieben.
- [x] Docker-Socket im aktuellen Pod geprüft: nicht vorhanden; daher kein lokaler Docker-Build möglich.

## Noch auszuführen

- [ ] Build und Tool-Smoketest auf einem vertrauenswürdigen Docker-Runner ausführen.
- [ ] Socket-Integrationstest auf einem Runner mit vorhandenem `/var/run/docker.sock` ausführen.
- [ ] CI und GHCR-Publishing nach Entscheidung zu Punkt 1 einrichten.
- [ ] SHA256-Verifikation für externe Tool-Downloads ergänzen.


## Resolution
- Keep the remote base and apply local updates for nvm/tenv and docs.
