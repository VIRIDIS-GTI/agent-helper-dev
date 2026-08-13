# Betriebsanweisung für agent-helper-dev

Du (der aufrufende Agent, nicht dieser Container selbst) rufst dieses Image
per `docker run` auf, wenn du ein Entwicklungswerkzeug brauchst, das in
deinem eigenen Container fehlt — git, kubectl, helm, terraform, ein
Build-Toolchain, etc. Diese Datei ist die aktuelle Version davon; sie liegt
im Image selbst (`/home/agent/AGENT_PROMPT.md`) und wandert mit jedem Update
mit — lies sie live aus dem Container, statt dich auf eine Kopie an anderer
Stelle zu verlassen:

```bash
docker run --rm ghcr.io/viridis-gti/agent-helper-dev:latest cat /home/agent/AGENT_PROMPT.md
```

## Der Workspace ist kein leerer Wegwerf-Container

Der Workspace-Mount (`--mount type=bind,src=<dein-workspace>,dst=/workspace`)
ist derselbe Pfad, den du selbst als dauerhaftes Arbeitsverzeichnis nutzt.
Bevor du irgendetwas neu klonst oder aufsetzt: sieh nach, ob es schon da ist
(`ls /workspace`). Ein zweiter Klon eines bereits vorhandenen Repos ist
verschwendete Zeit, kein Neuanfang.

## VIRIDIS-Infrastruktur-Repo: erst lesen, dann fragen

Für alles, was mit der VIRIDIS-Infrastruktur zu tun hat
(`infrastructure-monorepo`), gilt: **die README des Repos beantwortet die
meisten Fragen, die du dir sonst mühsam zusammensuchen würdest.** Lies sie
zuerst, bevor du explorierst.

**Geheimnisse sind verschlüsselt, nicht fehlend.** Jedes Repo mit
Zugangsdaten hält seine `.env` nur als `*.encrypted` (AES-256-CBC). Ein
fehlender Klartext-Wert heißt nicht "keine Credentials vorhanden", sondern
"noch nicht entschlüsselt":

```bash
./restore_secrets.sh   # entschlüsselt mit dem vorhandenen Schlüssel, installiert den pre-commit-Hook
```

**Brauchst du eine bestimmte Zugangsart (Cluster, Cloud-API, Registry, ...)
und ist sie nach dem Entschlüsseln immer noch nicht offensichtlich: sieh
zuerst im `scripts/`-Verzeichnis des Repos nach, ob es dafür schon ein
`get_<was-du-brauchst>`-Skript gibt**, bevor du das Fehlen der Credentials
meldest oder einen eigenen Weg dafür baust. Diese Skripte holen den Zugang
oft aus demselben Secrets-Store, den auch die Cluster-Manifeste nutzen
(AWS Secrets Manager, verschlüsselte `.env`, o. ä.) — von Hand nachbauen
duplizierte Arbeit, die schon gelöst ist.

Fehlt trotzdem etwas Konkretes (ein Schlüssel, den niemand hat, ein Zugang,
für den es kein Skript gibt): das ist ein einziges, klares Ergebnis für
deine Antwort — nicht ein Zwischenstand pro Versuch.

## Keine Zwischenmeldungen für jeden Erkundungsschritt

Klonen, README lesen, Secrets entschlüsseln, ein Skript suchen — das ist
alles Vorbereitung für die eigentliche Aufgabe, keine eigenen Ergebnisse.
Melde nicht "Ah, hier ist das Repo", "Ah, das geht nicht, weil...", "Ah, da
gibt es ja ein Skript..." als einzelne Nachrichten. Arbeite die Vorbereitung
im Hintergrund durch und antworte **einmal**, wenn die eigentliche Aufgabe
erledigt ist (oder wenn du endgültig feststeckst und weißt, woran genau).
