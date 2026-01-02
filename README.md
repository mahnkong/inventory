# Inventory (Inventory Management System)

A lightweight, mobile-friendly inventory tracking application. This project consists of a Ruby-based Sinatra backend and a Progressive Web App (PWA) frontend, designed for scanning and managing product stocks via barcodes.

The application uses the openfoodfacts API to fetch product data

Created as a fun project while moving into a new house with a log of storage space including several freezers.

## Project Structure

- **`backend/`**: A Sinatra-based Ruby API.
    - `app/`: Contains the core logic and models.
    - `config.ru`: Rack configuration for running the application.
    - `Gemfile`: Ruby dependencies (Sinatra, Openfoodfacts, Puma, etc.).
- **`haproxy/`**: Configuration and static assets.
    - `static/`: The frontend PWA (HTML, CSS, JS, and Service Workers).
    - `haproxy.cfg`: Reverse proxy configuration to glue the frontend and backend together.

## Tech Stack

- **Backend:** Ruby 3.4.2, Sinatra, Puma.
- **Frontend:** Vanilla JS (ES Modules), HTML5 (BarcodeDetector API), CSS3.
- **Infrastructure:** Docker, Docker Compose, HAProxy.

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Ruby 3.4.2 (if developing backend locally)

### Running with Docker

The easiest way to start the full stack is using Docker Compose:

Use latest container from gcr:
```
bash run.sh
```

Build container from sources and start:
```
DOCKER_COMPOSE_BUILD=true bash run.sh
```

The application will be accessible through the HAProxy load balancer (check `docker-compose.yml` for port mappings, usually port 80 or 443).

### Environment Configuration

1. Create a `.env` file in the root directory.
2. Define necessary environment variables (e.g., `AUTH_TOKEN` for API security).

## 📱 Frontend Features

- **Barcode Scanning:** Uses the browser's native `BarcodeDetector` API to scan items via the device camera.
- **Offline Support:** Implemented as a PWA with a Service Worker for caching.
- **IndexedDB:** Local storage of authentication tokens and cached inventory data.
- **Search & Filter:** Real-time filtering of inventory items.

## Development

### Backend

The backend is a Sinatra application. To install the dependencies, execute:

```aiignore
cd backend
bundle install
```
### Frontend
Static files are served from `haproxy/static/`. You can edit `index.html` to modify the UI.

## License

This project is licensed under the BSD 3-Clause License.

Commercial use is permitted, provided that the copyright notice and license text are retained in accordance with the license terms.