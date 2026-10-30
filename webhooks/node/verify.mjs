// Verify the X-Relay-Signature header of a Relay webhook (Node.js 18 or later, no dependency).
//
// Header: X-Relay-Signature: t=<unix seconds>,v1=<hex HMAC-SHA256 of "<t>.<raw body>">
// Use the raw request body, exactly as received, not a re-serialised JSON object.

import { createHmac, timingSafeEqual } from 'node:crypto';

/**
 * @param {string} rawBody   Raw request body.
 * @param {string} header    Value of the X-Relay-Signature header.
 * @param {string} secret    Your webhook signing secret.
 * @param {object} [options]
 * @param {number} [options.toleranceSeconds=300] Maximum age of the signature.
 * @param {number} [options.now] Current time in Unix seconds (for tests).
 * @returns {boolean} true when the signature is valid and recent.
 */
export function verifyRelaySignature(rawBody, header, secret, options = {}) {
  const tolerance = options.toleranceSeconds ?? 300;
  const now = options.now ?? Math.floor(Date.now() / 1000);
  if (!rawBody && rawBody !== '') return false;
  if (!header || !secret) return false;

  let timestamp = null;
  const signatures = [];
  for (const part of String(header).split(',')) {
    const [key, value] = part.trim().split('=', 2);
    if (key === 't' && /^\d+$/.test(value ?? '')) timestamp = Number(value);
    if (key === 'v1' && value) signatures.push(value.toLowerCase());
  }
  if (timestamp === null || signatures.length === 0) return false;
  if (Math.abs(now - timestamp) > tolerance) return false;

  const expected = Buffer.from(
    createHmac('sha256', secret).update(`${timestamp}.${rawBody}`).digest('hex'),
    'utf8',
  );
  return signatures.some((sig) => {
    const given = Buffer.from(sig, 'utf8');
    return given.length === expected.length && timingSafeEqual(given, expected);
  });
}

// Example receiver with the built-in HTTP server:
//
//   import { createServer } from 'node:http';
//   import { verifyRelaySignature } from './verify.mjs';
//
//   const seen = new Set(); // use your database in production
//   createServer((req, res) => {
//     let raw = '';
//     req.on('data', (chunk) => (raw += chunk));
//     req.on('end', () => {
//       if (!verifyRelaySignature(raw, req.headers['x-relay-signature'], process.env.RELAY_WEBHOOK_SECRET)) {
//         res.writeHead(401).end();
//         return;
//       }
//       const event = JSON.parse(raw);
//       if (!seen.has(event.id)) {
//         seen.add(event.id);
//         // handle event.event and event.data here, then answer quickly
//       }
//       res.writeHead(200).end('ok');
//     });
//   }).listen(3000);
