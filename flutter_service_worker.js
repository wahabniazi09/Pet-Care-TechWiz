'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "70274dece72b98665a4bba0a4a127c0c",
"assets/AssetManifest.bin.json": "08735edf8f74e7c0e8223758eed819bc",
"assets/AssetManifest.json": "62bf074d1f643b97139df14f8ca8f98e",
"assets/assets/icons/blogging.png": "6cd3ce70a21cccdbcb78f189ee4487a9",
"assets/assets/icons/cart.png": "90b3e501aa1111ba852f6fd43ad64a55",
"assets/assets/icons/categories.png": "3ee9b41a7bddf1e8bc86548f97f73358",
"assets/assets/icons/events.png": "8a5760cd1c1e3ed7cbca55cbdc595811",
"assets/assets/icons/home.png": "82b15439ecb4d4a776836d6d16f87d8b",
"assets/assets/icons/o-hamburger.png": "75540fbab9b867af5542e3173c23389a",
"assets/assets/icons/order.png": "4268c502251ef35d24afc32892de5ef9",
"assets/assets/icons/orders.png": "3639b858d6c5730b8e6705b62324772c",
"assets/assets/icons/placeholder.png": "4ee9d2e7f0e4ddc539dfb8c1b8ce5baf",
"assets/assets/icons/placeholder_rectangle.png": "a364b79d7d4ec9f2193789116a80819b",
"assets/assets/icons/plus.png": "042954477fb46729980bb2eca0ac2e9e",
"assets/assets/icons/points.png": "82988f05d354341ebce130b6cae90ec2",
"assets/assets/icons/profile.png": "531bb1c7a7dc201d1e77e8448358812b",
"assets/assets/icons/refund.png": "1d98ce7706455927116746d6009c4c20",
"assets/assets/icons/search.png": "c7cbc84f63ead800deb77cae175a1b8c",
"assets/assets/icons/settings.png": "b828d54764b59241981eec405c9e9f87",
"assets/assets/icons/shop.png": "170ac8257dcd4b2622ce8a8f37ea2921",
"assets/assets/icons/tracker.png": "e78ed8677252589d8c9941548bd65bb9",
"assets/assets/images/1_img.png": "3d8f54a3ee534de1e0e24677772fca36",
"assets/assets/images/background.png": "a5c631af551d21d3683a6a9e4c51cbf5",
"assets/assets/images/bg1.png": "bfe72fd41592c6008f096746efb80b80",
"assets/assets/images/boxer.webp": "47776952ebdd6b5fa064f297110413e5",
"assets/assets/images/Bulldog.jpg": "d82e2f8a1511455553f0eacf545d3629",
"assets/assets/images/catbag.webp": "7fda957bac742562c3f1a70da62e1f38",
"assets/assets/images/catfe.jpg": "d6f768b1cc3ac4838e0ca0e20259b393",
"assets/assets/images/catfood.webp": "eb5a77f7f4353d57d0b6d3cbd30c1d6f",
"assets/assets/images/catho.webp": "13f1805f390e491735d266b9600e4e61",
"assets/assets/images/dentaltoy.webp": "592957f4e1bea723bbff9a31f10e3e45",
"assets/assets/images/dogmass.webp": "4d441319c4fdd674965008dd3b3ec173",
"assets/assets/images/dooo.webp": "35abb2852cbf79921b883b7d8812a454",
"assets/assets/images/download.png": "1e30eba1c1afab133ca56bd7110fb60a",
"assets/assets/images/download1.png": "1721d6fb4022248cdd2015078e99cecb",
"assets/assets/images/download2.png": "1d679d5dc6473dbf36bbc9ce85d3a5b4",
"assets/assets/images/dt.webp": "786bebb7085a7d6571f73aa3adce887f",
"assets/assets/images/feverdo.jfif": "c92f17187ced244350f07c4bf14dc5ce",
"assets/assets/images/german.webp": "325de1db3d65d4c329713e1606ce2df2",
"assets/assets/images/health.jfif": "b28c0e8606513d1335bf0436cab71b3d",
"assets/assets/images/house1.webp": "0e06afaa02de9c4330ef3a6b39c7f32a",
"assets/assets/images/house123.jpg": "b617198061f12883580fc3dbd79a1971",
"assets/assets/images/husky.webp": "e9bfb8f767bb25b6203a2a913153e7fe",
"assets/assets/images/pet123.png": "ccf60dbcea55ab3aa9a98c89f43e0d58",
"assets/assets/images/peticon.png": "d7ca44ae7358be68a6f640b5698a2f19",
"assets/assets/images/pet_logo.ico": "1eca26c5022b6444dcbe9f8887802e07",
"assets/assets/images/pet_logo.png": "e0d25a67ee9880a5412686b96f9f2a53",
"assets/assets/images/pitbull.jpg": "3323a47f3d202ae3d0927ecbc7d6074a",
"assets/assets/images/ropetoy.webp": "a3804539b2e60eaee15d0215d6fe0460",
"assets/assets/images/Rottweiler.webp": "220bc34b924f842eda720a2036810662",
"assets/assets/images/toy1.jfif": "62cb000a7c071d655f31aaa191351a8c",
"assets/assets/images/toybon1.jfif": "cf4c93c2a8e23f4ab641301c4629581a",
"assets/assets/images/wetff.webp": "31baca0f49fe30d7ed63cc9c8cd7fe0e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "73ca5267e054a086eb4563db72f678c2",
"assets/NOTICES": "ff4f2e06ea616f58548eb3ae839fb0ac",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "7286f70609df6757b2511db9f6c1c257",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "8a3575ad28e47138d7b94aded5389877",
"/": "8a3575ad28e47138d7b94aded5389877",
"main.dart.js": "d3f11bfed1aa6b583c37a22007a04bb3",
"manifest.json": "efbf8877dd815116c32054b7247ac26a",
"version.json": "90376e2293e308c60545a56f00a2dddc"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
