# Aetheris MVP: Lightweight Zero Trust Stack

Aetheris MVP is a stripped-down, single-tenant implementation of the complex multi-tenant Aetheris IAM architecture. It provides a lightweight Zero Trust stack designed to improve performance, maintainability, and operational simplicity for private infrastructure usage.

## Architecture

This MVP simplifies the architecture to focus only on essential security components:

- **Identity Provider (IdP)**: [Keycloak](https://www.keycloak.org/) manages user identities and issues JWT tokens.
- **Identity-Aware Proxy (IAP)**: [Ory Oathkeeper](https://www.ory.sh/oathkeeper/) sits in front of the backend services, acting as a gatekeeper that validates tokens.
- **Policy Engine**: [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) executes static access control policies (ABAC/RBAC) to determine if a request is authorized.
- **Protected Resource**: A dummy backend (`traefik/whoami`) used to verify the authentication and authorization flow.

### Flow
1. **Client** authenticates with **Keycloak** to obtain a JWT.
2. **Client** sends a request to the protected backend via the **Oathkeeper Proxy**.
3. **Oathkeeper** extracts the JWT, verifies its signature, and forwards the context to **OPA**.
4. **OPA** evaluates the request against static policies (`authz.rego`) and returns a decision.
5. If authorized, **Oathkeeper** forwards the request to the target backend service.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/MDPN23/aeetheris-mvp.git
   cd aeetheris-mvp
   ```

2. Start the services using Docker Compose:
   ```bash
   docker-compose up -d
   ```

3. The services will take a few moments to initialize (Keycloak requires some time to start up and import the `aetheris` realm). You can check the status using:
   ```bash
   docker-compose ps
   ```

## Service Endpoints

Once the stack is running, the following endpoints are available:

| Service | Endpoint | Description |
|---|---|---|
| **Keycloak Admin Console** | `http://localhost:8080/admin` | Credentials: `admin` / `admin` |
| **Oathkeeper Proxy** | `http://localhost:4455` | Routes requests to protected backend |
| **Oathkeeper API** | `http://localhost:4456` | Management API for Oathkeeper |
| **OPA API** | `http://localhost:8181` | OPA policy evaluation endpoint |
| **PostgreSQL** | `localhost:5432` | DB Credentials: `aetheris_admin` / `aetheris_password` |
| **Target Backend (Direct)** | `http://localhost:5000` | Unprotected `whoami` service (for testing purposes) |

## Configuration & Policies

- **Keycloak Realm**: The `aetheris` realm is automatically imported on startup from `keycloak/realm-export.json`.
- **Oathkeeper Rules**: Routing and authentication rules are defined in `oathkeeper/rules.json`.
- **OPA Policies**: Authorization rules are defined in `opa/authz.rego`. Any changes to this file require an OPA container restart (`docker-compose restart opa`) to take effect.

## Shutting Down

To stop and remove all containers, networks, and volumes:

```bash
docker-compose down -v
```
