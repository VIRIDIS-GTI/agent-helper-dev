# agent-helper-dev

Ein interaktives Entwicklungs-Image für Paperclip- und OpenClaw-Agenten. Es bringt die üblichen Werkzeuge zum Bearbeiten, Testen, Bauen und Ausrollen von Software mit. Der Arbeitsbereich wird immer vom aufrufenden System nach `/workspace` gemountet; dadurch bleiben Quellcode, virtuelle Umgebungen und lokale Build-Artefakte über Container-Neustarts erhalten.

> **Sicherheitsgrenze:** Ein gemounteter Docker-Socket verleiht dem Container weitreichende Rechte auf den Docker-Host. Er ist nur für vertrauenswürdige Agenten und isolierte Runner gedacht. Zugangsdaten niemals in das Image bauen oder in ein Image-Layer schreiben.

## Enthaltene Werkzeuge

| Bereich | Werkzeuge |
| --- | --- |
| Shell und Basis | Bash, sudo, curl, wget, jq, yq, less, unzip, zip, ping |
| Source Control und Secrets | Git, OpenSSH-Client, GnuPG, OpenSSL, rsync |
| Build | make, GCC/G++, build-essential, ShellCheck |
| JavaScript | Node.js 22 LTS, npm, Corepack (aktiviert: `pnpm` und `yarn`) |
| Node-Versionierer | `nvm` (installiert im Dockerfile) |
| Multi-Tool-Versionierer | `tenv` von <https://github.com/tofuutils/tenv> (installiert im Dockerfile) |
| Python | Python 3, pip, venv |
| Container | Docker CLI (`docker-ce-cli`), Buildx über die Docker-CLI |
| Plattform | kubectl, Helm, Terraform |
| Medien | ffmpeg |

Die Liste ist aus der Installation des VIRIDIS Dev Bot abgeleitet und bewusst auf Entwicklungswerkzeuge reduziert. Die vollständige Zuordnung von Host-Tools zu Image-Paketen steht in [`TOOLING.md`](TOOLING.md).

## Bauen

```bash
git clone https://github.com/VIRIDIS-GTI/agent-helper-dev.git
cd agent-helper-dev
docker build -t ghcr.io/viridis-gti/agent-helper-dev:local .
```

Der Build benötigt ausgehenden Zugriff auf die offiziellen APT-, NodeSource-, Docker-, Kubernetes-, Helm-, yq- und HashiCorp-Releases.

## Interaktiv verwenden

Der Workspace ist das Home-/Startverzeichnis der Agentenarbeit und muss als beschreibbares Volume gemountet werden:

```bash
docker run --rm -it \
  --name agent-helper-dev \
  --mount type=bind,src="$PWD",dst=/workspace \
  -w /workspace \
  ghcr.io/viridis-gti/agent-helper-dev:local
```

Für parallele, nicht-interaktive Aufrufe denselben Workspace mounten:

```bash
docker run --rm \
  --mount type=bind,src="$PWD",dst=/workspace \
  -w /workspace \
  ghcr.io/viridis-gti/agent-helper-dev:local \
  bash -lc 'git status && pnpm --version && python3 --version'
```

## Docker-Socket (optional und privilegiert)

Um Images auf dem Host zu bauen oder vorhandene Host-Container zu steuern, den Socket explizit bereitstellen:

```bash
docker run --rm -it \
  --mount type=bind,src="$PWD",dst=/workspace \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  -w /workspace \
  ghcr.io/viridis-gti/agent-helper-dev:local \
  docker version
```

Der Socket muss auf dem Host existieren und für den Container-Prozess les- und schreibbar sein. Bei Socket-Gruppenrechten den Container bei Bedarf als root ausführen (`--user 0`) oder eine passende Gruppen-ID ergänzen (`--group-add "$(stat -c %g /var/run/docker.sock)"`). Nicht zusammen mit untrusted Code oder Secrets verwenden.

## Zugangsdaten

Bevorzugt temporäre, read-only oder kurzlebige Secrets gezielt durchreichen. Beispiele:

```bash
# SSH-Agent statt privatem Schlüssel im Environment
docker run --rm -it \
  --mount type=bind,src="$PWD",dst=/workspace \
  --mount type=bind,src="$SSH_AUTH_SOCK",dst=/ssh-agent \
  -e SSH_AUTH_SOCK=/ssh-agent \
  ghcr.io/viridis-gti/agent-helper-dev:local

# Token nur für den einzelnen Lauf; nicht in Shell-History oder Dockerfile schreiben
docker run --rm -it \
  --mount type=bind,src="$PWD",dst=/workspace \
  -e GITHUB_TOKEN \
  ghcr.io/viridis-gti/agent-helper-dev:local
```

`~/.ssh`, Secret-Dateien und komplette Docker-Konfigurationen nur dann mounten, wenn der konkrete Auftrag es erfordert. Sie dürfen nicht in Git eingecheckt werden.

## Test-Checkliste

```bash
docker build -t agent-helper-dev:test .
docker run --rm agent-helper-dev:test bash -lc \
  'node --version && pnpm --version && git --version && docker --version && kubectl version --client && helm version && terraform version'
# nur auf einem vertrauenswürdigen Docker-Host mit vorhandenem Socket:
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock agent-helper-dev:test docker version
```

Offene Designentscheidungen und Verbesserungsvorschläge stehen in [`TBD.md`](TBD.md).
