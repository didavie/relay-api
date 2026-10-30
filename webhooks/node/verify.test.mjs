import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { verifyRelaySignature } from './verify.mjs';

const vector = JSON.parse(readFileSync(new URL('../fixtures/vector.json', import.meta.url), 'utf8'));
const now = vector.timestamp + 10;

test('accepts the test vector', () => {
  assert.equal(verifyRelaySignature(vector.body, vector.signature_header, vector.secret, { now }), true);
});

test('refuses a changed body', () => {
  assert.equal(verifyRelaySignature(`${vector.body} `, vector.signature_header, vector.secret, { now }), false);
});

test('refuses a wrong secret', () => {
  assert.equal(verifyRelaySignature(vector.body, vector.signature_header, 'whsec_other', { now }), false);
});

test('refuses an old signature', () => {
  assert.equal(
    verifyRelaySignature(vector.body, vector.signature_header, vector.secret, { now: vector.timestamp + 301 }),
    false,
  );
});

test('refuses a malformed header', () => {
  assert.equal(verifyRelaySignature(vector.body, 'v1=abc', vector.secret, { now }), false);
  assert.equal(verifyRelaySignature(vector.body, '', vector.secret, { now }), false);
});
