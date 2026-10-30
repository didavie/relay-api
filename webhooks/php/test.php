<?php
/**
 * Tests for verify.php: php webhooks/php/test.php
 */

require __DIR__ . '/verify.php';

$vector = json_decode( file_get_contents( __DIR__ . '/../fixtures/vector.json' ), true );
$now    = $vector['timestamp'] + 10;
$failed = 0;

$cases = array(
	'accepts the test vector'  => relay_verify_signature( $vector['body'], $vector['signature_header'], $vector['secret'], 300, $now ),
	'refuses a changed body'   => ! relay_verify_signature( $vector['body'] . ' ', $vector['signature_header'], $vector['secret'], 300, $now ),
	'refuses a wrong secret'   => ! relay_verify_signature( $vector['body'], $vector['signature_header'], 'whsec_other', 300, $now ),
	'refuses an old signature' => ! relay_verify_signature( $vector['body'], $vector['signature_header'], $vector['secret'], 300, $vector['timestamp'] + 301 ),
	'refuses a bad header'     => ! relay_verify_signature( $vector['body'], 'v1=abc', $vector['secret'], 300, $now ),
);

foreach ( $cases as $name => $ok ) {
	echo ( $ok ? 'ok   ' : 'FAIL ' ) . $name . "\n";
	if ( ! $ok ) {
		++$failed;
	}
}
exit( $failed ? 1 : 0 );
