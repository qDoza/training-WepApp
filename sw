// Меняй номер версии, когда обновляешь index.html
const CACHE = “workout-v1”;
const FILES = [
“./”,
“./index.html”,
“./manifest.webmanifest”,
“./icon-180.png”,
“./icon-512.png”
];

self.addEventListener(“install”, e => {
e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)));
self.skipWaiting();
});

self.addEventListener(“activate”, e => {
e.waitUntil(
caches.keys().then(keys =>
Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
)
);
self.clients.claim();
});

// Сначала отдаём из памяти телефона, в фоне обновляем с сайта
self.addEventListener(“fetch”, e => {
if (e.request.method !== “GET”) return;
e.respondWith(
caches.match(e.request).then(hit => {
const net = fetch(e.request)
.then(res => {
const copy = res.clone();
caches.open(CACHE).then(c => c.put(e.request, copy));
return res;
})
.catch(() => hit || caches.match(”./index.html”));
return hit || net;
})
);
});