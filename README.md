# WiraChain Platform

**WiraChain** is a healthcare platform that improves clinical data interoperability by combining **HL7 FHIR R4** with a permissioned **Hyperledger Besu** blockchain. Clinical records stay in conventional/FHIR storage, while patient consent decisions (grant/revoke) are recorded on-chain as an immutable, verifiable audit trail.

This repository is the **platform superproject**: it does not reimplement the application, it wires every independent repository together as Git submodules so the whole system can be cloned, versioned and started consistently.

## Architecture

```
Browser ──► React frontend ──► .NET 8 REST API ──┬──► MySQL (identity & domains)
                                                ├──► HAPI FHIR R4 (clinical records)
                                                └──► Besu + Solidity contract (consent audit)
                                                        ▲
                                         Smart-contract ABI/event API
```

Four roles are supported: **patient**, **doctor**, **clinic administrator** and **system administrator**. Patients control who can access their data; the blockchain records the authorization outcome without storing protected health information.

## Repository structure

The platform uses Git submodules. Every folder below is an independent repository pinned to a specific commit:

| Folder | Repository | Responsibility |
| --- | --- | --- |
| `wirachain-backend/` | [xenocore-wirachain/wirachain-backend](https://github.com/xenocore-wirachain/wirachain-backend) | ASP.NET Core REST API, domain logic, FHIR and Ethereum integrations |
| `wirachain-frontend/` | [xenocore-wirachain/wirachain-frontend](https://github.com/xenocore-wirachain/wirachain-frontend) | React SPA with role-based dashboards |
| `wirachain-smart-contract-deployment/` | [xenocore-wirachain/wirachain-smart-contract-deployment](https://github.com/xenocore-wirachain/wirachain-smart-contract-deployment) | Solidity contracts, CLI compile/deploy tooling, ABI dispatcher and event-query API |
| `wirachain-datasets/` | [xenocore-wirachain/wirachain-datasets](https://github.com/xenocore-wirachain/wirachain-datasets) | Synthetic entities, event logs, latency and TPS datasets used for validation |
| `wirachain-docker/` | [xenocore-wirachain/wirachain-docker](https://github.com/xenocore-wirachain/wirachain-docker) | Docker Compose stack for the entire platform |

The connections are declarative: `wirachain-docker/docker-compose.yml` builds the backend, frontend and contract API from their sibling submodule folders and wires them to MySQL, HAPI FHIR and Besu by container name.

## Technologies

- **Frontend:** React 19, TypeScript, Vite 6, Redux Toolkit / RTK Query, React Router 7, PrimeReact, Tailwind CSS, Vitest
- **Backend:** .NET 8 / ASP.NET Core Web API, Entity Framework Core + MySQL, JWT + BCrypt, AutoMapper, Swagger, HL7 FHIR R4 (`Hl7.Fhir.R4`), Nethereum
- **Blockchain:** Hyperledger Besu (QBFT in production topology, dev node in Compose), Solidity 0.8.26, ethers.js v6, Node.js/Express contract API
- **Interoperability:** HAPI FHIR server, HL7 FHIR R4 resources
- **Data:** MySQL 8.0, CSV datasets (entities, event logs, latency, TPS)
- **Infrastructure:** Docker, Docker Compose, Nginx, AWS-oriented deployment described in the article

## Features

- Patient-controlled permission grant/revoke with on-chain event emission (no clinical data on-chain)
- FHIR R4 patient record create/update/delete against an external HAPI FHIR server
- Authentication with JWT and role-based access control for four dashboards
- CRUD and paginated search for clinics, doctors, patients, specialties, tests and consultations
- Chunked on-chain event queries filtered by pseudonymized patient GUID and clinic ID
- Reproducible synthetic datasets and performance measurements (latency/TPS) from the validation study
- One-command local stack through Docker Compose

## Getting started

### 1. Clone with submodules

```bash
git clone --recurse-submodules https://github.com/xenocore-wirachain/platform.git
cd platform
```

If you already cloned the platform without submodules:

```bash
git submodule update --init --recursive
```

To advance every submodule to the latest commit on its default branch:

```bash
git submodule update --remote --recursive
```

### 2. Configure and start the full stack

```bash
cd wirachain-docker
cp .env.template .env      # fill in credentials and ports
docker compose up -d --build
```

| URL | Service |
| --- | --- |
| `http://localhost:3000` | Frontend |
| `http://localhost:5273/swagger` | Backend API docs |
| `http://localhost:8080/fhir` | HAPI FHIR endpoint |
| `http://localhost:4121/api-docs` | Smart-contract API docs |

Ports are driven by `.env` (`BACKEND_PORT`, `FRONTEND_PORT`, `FHIR_PORT`, `BESU_RPC_PORT`, `ABI_DISPATCHER_PORT`). See [`wirachain-docker/README.md`](wirachain-docker/README.md) for service details and deployment notes.

### 3. Work on a single component

Each submodule has its own README and can be developed independently:

```bash
# Backend
cd wirachain-backend && dotnet restore && dotnet run

# Frontend
cd wirachain-frontend && npm install && npm run dev

# Contract tooling
cd wirachain-smart-contract-deployment && npm install && npm run build
```

Before emitting on-chain events, compile and deploy the permission contract to the Besu node using the CLI helpers in `wirachain-smart-contract-deployment/scripts/` and update the stored address artifact. `EthereumSettings__SmartContractManagerUrl` must point to a service exposing `GET /contract/1` with the ABI and address.

## Related articles

If you use this platform in research, please cite the following works.

**Journal article (APA 7):**

Grau, L., Urrunaga, J., & Santisteban, J. (2026). WiraChain: A blockchain and FHIR-based platform for improving clinical data interoperability in healthcare. *Frontiers in Public Health, 14*, Article 1746772. https://doi.org/10.3389/fpubh.2026.1746772

**Conference paper (APA 7):**

Grau, L., Urrunaga, J., & Santisteban, J. (2026). Wirachain: Blockchain and Fast Healthcare Interoperability Resources for clinical data interoperability. In *2026 International Conference on Artificial Intelligence, Computer, Data Sciences and Applications (ACDSA)* (pp. 1–6). IEEE. https://doi.org/10.1109/ACDSA67686.2026.11468238

- [Frontiers in Public Health article](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2026.1746772/full)
- [IEEE ACDSA 2026 paper](https://ieeexplore.ieee.org/document/11468238)
