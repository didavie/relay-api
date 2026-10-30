<?php
/**
 * Verify the X-Relay-Signature header of a Relay webhook (PHP 7.4 or later, no dependency).
 *
 * Header: X-Relay-Signature: t=<unix seconds>,v1=<hex HMAC-SHA256 of "<t>.<raw body>">
 * Use the raw request body (file_get_contents('php://input')), not a re-encoded array.
 */

/**
 * @param string   $raw_body  Raw request body.
 * @param string   $header    Value of the X-Relay-Signature header.
 * @param string   $secret    Your webhook signing secret.
 * @param int      $tolerance Maximum age of the signature, in seconds.
 * @param int|null $now       Current Unix time (for tests).
 * @return bool True when the signature is valid and recent.
 */
function relay_verify_signature( $raw_body, $header, $secret, $tolerance = 300, $now = null ) {
	if ( '' === (string) $header || '' === (string) $secret ) {
		return false;
	}
	$now        = null === $now ? time() : (int) $now;
	$timestamp  = null;
	$signatures = array();
	foreach ( explode( ',', (string) $header ) as $part ) {
		$pair = explode( '=', trim( $part ), 2 );
		if ( 2 !== count( $pair ) ) {
			continue;
		}
		if ( 't' === $pair[0] && ctype_digit( $pair[1] ) ) {
			$timestamp = (int) $pair[1];
		} elseif ( 'v1' === $pair[0] && '' !== $pair[1] ) {
			$signatures[] = strtolower( $pair[1] );
		}
	}
	if ( null === $timestamp || ! $signatures || abs( $now - $timestamp ) > $tolerance ) {
		return false;
	}
	$expected = hash_hmac( 'sha256', $timestamp . '.' . $raw_body, $secret );
	foreach ( $signatures as $signature ) {
		if ( hash_equals( $expected, $signature ) ) {
			return true;
		}
	}
	return false;
}

/*
 * Example receiver (plain PHP):
 *
 * $raw    = file_get_contents( 'php://input' );
 * $header = isset( $_SERVER['HTTP_X_RELAY_SIGNATURE'] ) ? $_SERVER['HTTP_X_RELAY_SIGNATURE'] : '';
 * if ( ! relay_verify_signature( $raw, $header, getenv( 'RELAY_WEBHOOK_SECRET' ) ) ) {
 *     http_response_code( 401 );
 *     exit;
 * }
 * $event = json_decode( $raw, true );
 * // Skip $event['id'] if you already handled it, then handle $event['event'] and $event['data'].
 * http_response_code( 200 );
 * echo 'ok';
 */
