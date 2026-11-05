/**
 * Cloud Functions de la Biblia Boricua.
 *
 *  - versiculoDelDia: cada mañana a las 7:00 (hora de Puerto Rico) envía por
 *    push el versículo del día al tema "boricua-versiculo-del-dia".
 *  - limpiarCuenta: al borrar una cuenta, borra sus datos (users/{uid}).
 *
 * Despliegue: cd functions && npm install && npm run deploy
 */
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import * as functionsV1 from 'firebase-functions/v1';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import versiculos from './versiculos.json';

initializeApp();

type Versiculo = { reference: string; text: string; study: string };

/** El mismo versículo para todos durante el día; cambia cada día. */
export function versiculoDe(fecha: Date, lista: Versiculo[] = versiculos): Versiculo {
  const dia = Math.floor(Date.UTC(fecha.getUTCFullYear(), fecha.getUTCMonth(), fecha.getUTCDate()) / 86400000);
  return lista[((dia % lista.length) + lista.length) % lista.length];
}

export const versiculoDelDia = onSchedule(
  { schedule: '0 7 * * *', timeZone: 'America/Puerto_Rico', region: 'us-east1' },
  async () => {
    const v = versiculoDe(new Date());
    await getMessaging().send({
      topic: 'boricua-versiculo-del-dia',
      notification: { title: `Versículo del día · ${v.reference}`, body: v.text },
      data: { route: `/palabra/${v.study}` },
      android: { priority: 'normal', notification: { channelId: 'versiculo-del-dia' } },
    });
  },
);

export const limpiarCuenta = functionsV1.auth.user().onDelete(async (user) => {
  await getFirestore().collection('users').doc(user.uid).delete();
});
