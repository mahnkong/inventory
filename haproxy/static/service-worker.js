const CACHE_NAME = "inventory-cache-v1";

// Liste der beim Installieren gecachten Ressourcen
const PRECACHED_ASSETS = [
    "/inventory/index.html",
    "/inventory/manifest.json",
    "/inventory/assets/icon-192.png",
];

// --- Install ---
self.addEventListener("install", (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => cache.addAll(PRECACHED_ASSETS))
    );
    self.skipWaiting();
});

self.addEventListener("activate", (event) => {
    event.waitUntil(
        caches.keys().then((keys) =>
            Promise.all(
                keys.map((key) => {
                    if (key !== CACHE_NAME) {
                        return caches.delete(key);
                    }
                })
            )
        )
    );
    self.clients.claim();
});

// --- Fetch ---
self.addEventListener("fetch", (event) => {
    const requestUrl = event.request.url;

    // Ignoriere alles, was nicht http(s) ist
    if (!requestUrl.startsWith("http")) return;

    // Prüfe, ob diese Request-URL in der Precache-Liste ist
    const isPrecached = PRECACHED_ASSETS.some((asset) =>
        requestUrl.includes(asset)
    );

    // Nur für vorinstallierte Assets Caching-Logik anwenden
    if (!isPrecached) return;

    event.respondWith(
        fetch(event.request)
            .then((response) => {
                // Bei Erfolg optional aktualisieren
                if (response && response.status === 200) {
                    const clone = response.clone();
                    caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
                }
                return response;
            })
            .catch(() => {
                // Fallback auf Cache, falls Netzwerk fehlschlägt
                return caches.match(event.request);
            })
    );
});