# AFFiNE Fork Conventions (Single Source of Truth)

Authoritative guide for pelvity’s AFFiNE fork. Applies to Docker, Compose, Git, env files, releases, ports, docs, and security. Update this file whenever a new convention is agreed upon.

---

## 1. Source Control & Branching

| Item                 | Convention                              | Example                                    |
| -------------------- | --------------------------------------- | ------------------------------------------ |
| Default branch       | `main` mirrors upstream AFFiNE          | `main`                                     |
| Feature branches     | `<scope>/<topic>`                       | `feature/graph-view`, `infra/port-handoff` |
| Environment branches | `env/<env>-<purpose>`                   | `env/prod-hardening`, `env/dev-ci`         |
| Hotfix branches      | `hotfix/<issue>`                        | `hotfix/login-timeout`                     |
| Tags                 | CalVer or SemVer (match container tags) | `prod-20250203`, `v1.4.0`                  |

Commit style: Conventional Commits (`feat:`, `fix:`, `chore:`) to enable auto-changelog. Pull requests titled `<scope>: <summary>` with a checklist covering tests, docs, and Compose changes.

---

## 2. Docker Images & Tags

- Repositories: `pelvity/affine-backend`, `pelvity/affine-frontend`, `pelvity/gemini-bridge`.
- Tags:
  1. `latest` – dev tip, never deployed to prod.
  2. `prod-YYYYMMDD` – CalVer promotion tags (immutable), e.g., `pelvity/affine-backend:prod-20250203`.
  3. Optional SemVer + suffix for major releases (`v1.4.0-prod`).
- Image labels: set `org.opencontainers.image.revision`, `org.opencontainers.image.created`, `org.opencontainers.image.source`.
- Build args/targets: prefer multi-stage Dockerfiles; dev uses `Dockerfile.dev`, prod will use `Dockerfile.prod` once added.

---

## 3. Compose Services, Containers, Networks, Volumes

| Resource            | Pattern                      | Example                                                             |
| ------------------- | ---------------------------- | ------------------------------------------------------------------- |
| Service & container | `<product>_<role>_<env>`     | `affine_backend_prod`, `affine_backend_dev`, `affine_backend_local` |
| Networks            | `<product>_<env>_net`        | `affine_prod_net`, `affine_dev_net`                                 |
| Volumes             | `<product>_<resource>_<env>` | `affine_prod_pgdata`, `affine_dev_config`                           |

Compose file naming: `docker-compose.<env>[.<scope>].override.yml` (e.g., `docker-compose.prod.local.override.yml`, `docker-compose.dev.ec2.override.yml`).

---

## 4. Environment Files & Secrets

| File              | Purpose                                      |
| ----------------- | -------------------------------------------- |
| `.env.example`    | Onboarding reference                         |
| `.env.prod`       | Checked-in defaults (non-secret)             |
| `.env.prod.local` | Local prod secrets & host paths (gitignored) |
| `.env.dev`        | Shared dev defaults                          |
| `.env.dev.local`  | Developer overrides (gitignored)             |

Variable naming:

- Product toggles: `AFFINE_<FEATURE>`
- Database: `DB_*`
- External services: `<SERVICE>_*` (e.g., `GEMINI_BRIDGE_URL`).
- URLs use full protocol (e.g., `AFFINE_SERVER_EXTERNAL_URL=http://localhost:3010`).

Secrets management:

- Never commit credentials; store in `.env.*.local` or Doppler/Vault when on EC2.
- For CI, inject via GitHub Actions secrets.

---

## 5. Port & URL Policy

- Backend container listens on **3010** internally.
- Host mapping:
  - Production + local prod: host `3010 -> 3010`.
  - Development + local dev: host `3011 -> 3010`.
- Frontend dev server reads `AFFINE_SERVER_URL` (set in `.env.dev.local`). Default dev proxy → `http://localhost:3011`; prod lessons use `http://localhost:3010`.
- Gemini bridge internal port `8765`; never exposed publicly.
- Document every exposed port in `DOCKER_ENVIRONMENTS_README.md`.

---

## 6. Releases & Artifacts

- Git tag = Docker tag (CalVer or SemVer).
- Release packages named `affine-<env>-<tag>.tar.gz` (e.g., `affine-prod-20250203.tar.gz`).
- Attach compose overrides and `.env` templates to release notes.
- Keep changelog entries under `## [prod-YYYYMMDD]` with sections: Added / Changed / Fixed / Ops.

---

## 7. Storage Paths & Volumes

- Windows local prod: `C:\\Users\\admin\\.affine\\prod\\{config,storage,postgres\\pgdata}`.
- Windows local dev: `C:\\Users\\admin\\.affine\\dev\\...`.
- EC2: `/home/ec2-user/.affine/<env>/{config,storage,postgres/pgdata}`.
- Backups named `affine-<env>-postgres-YYYYMMDD.sql` stored under `backups/<env>/`

---

## 8. Logging, Monitoring, & Health Checks

- Docker logging driver: `json-file`, `max-size=10m`, `max-file=3`.
- Health check naming: `affine_<service>_<env>_health`.
- Centralize log collection under `C:\\Users\\admin\\.affine\\logs` (bind mount optional).
- Alerts for:
  - Backend container restart loops.
  - Prisma migration failures.
  - Port binding conflicts (Windows reserved ports list).

---

## 9. Security & Access

- SSH host alias: `aws-kacperjakub2099` (documented in `.ssh/config`).
- Docker registry access via `ghcr.io` using `gh auth refresh -s read:packages` then `docker login`.
- Rotate secrets quarterly; track in `SECURITY.md`.
- Never expose Postgres/Redis ports externally; rely on Compose network.

---

## 10. Documentation & Runbooks

- Store architecture decisions in `docs/ADR-<nn>-<topic>.md`.
- Operational runbooks (`DOCKER_ENV_SETUP_SUMMARY.md`, etc.) must reference this file for naming expectations.
- When updating conventions, include PR checklist item "Update NAMING_CONVENTIONS.md".

---

## 11. Testing & CI

- Test command naming: `yarn test:<scope>` (e.g., `yarn test:server`).
- CI workflow names: `ci-dev`, `ci-prod`, `ci-lint`, matching GitHub Actions files.
- Docker images built in CI must push both `latest` (or `dev`) and `prod-YYYYMMDD` tags.

---

Adhering to these conventions keeps docker resources, git history, and environment configs self-documenting and prevents conflicts when multiple stacks run side-by-side.
