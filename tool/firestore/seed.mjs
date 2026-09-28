// Publica assets/data/content.json en Firestore (content/current).
//
// Uso:
//   cd tool/firestore && npm install
//   GOOGLE_APPLICATION_CREDENTIALS=/ruta/cuenta-servicio.json node seed.mjs
//
// La app descarga el documento solo si su "version" es mayor que la que ya
// tiene, así que incrementa "version" en content.json antes de publicar.
import { readFileSync } from 'node:fs';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

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
      'Incrementa "version" en assets/data/content.json.',
  );
  process.exit(1);
}

// Un único documento (~125 KB, bajo el límite de 1 MiB de Firestore).
await ref.set(content);
console.log(`Publicadas ${content.passages.length} palabras (versión ${content.version}).`);
