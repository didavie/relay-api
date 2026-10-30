import json
import pathlib
import unittest

from relay_webhook import verify_relay_signature

VECTOR = json.loads((pathlib.Path(__file__).parent.parent / "fixtures" / "vector.json").read_text())
NOW = VECTOR["timestamp"] + 10


class VerifyRelaySignatureTest(unittest.TestCase):
    def test_accepts_the_test_vector(self):
        self.assertTrue(verify_relay_signature(VECTOR["body"], VECTOR["signature_header"], VECTOR["secret"], now=NOW))

    def test_accepts_bytes(self):
        body = VECTOR["body"].encode("utf-8")
        self.assertTrue(verify_relay_signature(body, VECTOR["signature_header"], VECTOR["secret"], now=NOW))

    def test_refuses_a_changed_body(self):
        self.assertFalse(verify_relay_signature(VECTOR["body"] + " ", VECTOR["signature_header"], VECTOR["secret"], now=NOW))

    def test_refuses_a_wrong_secret(self):
        self.assertFalse(verify_relay_signature(VECTOR["body"], VECTOR["signature_header"], "whsec_other", now=NOW))

    def test_refuses_an_old_signature(self):
        old = VECTOR["timestamp"] + 301
        self.assertFalse(verify_relay_signature(VECTOR["body"], VECTOR["signature_header"], VECTOR["secret"], now=old))

    def test_refuses_a_malformed_header(self):
        self.assertFalse(verify_relay_signature(VECTOR["body"], "v1=abc", VECTOR["secret"], now=NOW))
        self.assertFalse(verify_relay_signature(VECTOR["body"], "", VECTOR["secret"], now=NOW))


if __name__ == "__main__":
    unittest.main()
