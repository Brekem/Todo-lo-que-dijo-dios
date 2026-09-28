// Publica assets/data/content.json en Firestore.
//
// Uso:
//   cd tool/firestore && npm install
//   GOOGLE_APPLICATION_CREDENTIALS=/ruta/cuenta-servicio.json node seed.mjs
//
// Estructura:
//   content/current                 → { version, translation, eras, categories, chunks }
//   content/current/chunks/{0..n-1} → { passages: [...] }   (≤ 1 MiB por documento)
//
// La app descarga el contenido solo si su "version" es mayor que la que ya tiene:
// incrementa CONTENT_VERSION en tool/build_content.py antes de publicar.
import { readFileSync } from 'node:fs';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const CHUNK_SIZE = 250;

const content = JSON.parse(
  readFileSync(new URL('../../assets/data/content.json', import.meta.url), 'utf8'),
);

initializeApp({ credential: applicationDefault() });
const db = getFirestore();
const ref = db.collection('content').doc('current');

const current = await ref.get();
const remoteVersion = current.exists ? current.data().version ?? 0 : 0;
if (content.version <= remoteVersion) {
  console.error(
    `La versión local (${content.version}) no es mayor que la publicada (${remoteVersion}). ` +
      'Incrementa CONTENT_VERSION en tool/build_content.py.',
  );
  process.exit(1);
}

const { passages, ...meta } = content;
const chunks = [];
for (let i = 0; i < passages.length; i += CHUNK_SIZE) {
  chunks.push(passages.slice(i, i + CHUNK_SIZE));
}

// Primero las partes y al final el documento principal con la nueva versión:
// así la app nunca ve una versión nueva con partes a medio subir.
for (const [i, part] of chunks.entries()) {
  await ref.collection('chunks').doc(String(i)).set({ passages: part });
}
await ref.set({ ...meta, chunks: chunks.length });
console.log(
  `Publicadas ${passages.length} palabras en ${chunks.length} partes (versión ${content.version}).`,
);
