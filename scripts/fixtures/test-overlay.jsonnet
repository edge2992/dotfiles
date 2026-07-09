// Test fixture for scripts/check-json-tmpl.sh — mirrors the shape of a real
// company overlay (the function(base, data) contract) without real values.
function(base, data) base + {
  env+: { TEST_OVERLAY: data.test_secret },
  hooks+: {
    PermissionRequest: [
      { matcher: '', hooks: [{ type: 'command', command: 'true' }] },
    ],
  },
  enabledPlugins+: { 'test-plugin@test-marketplace': true },
  extraKnownMarketplaces+: {
    'test-marketplace': {
      source: { source: 'git', url: 'https://example.invalid/marketplace.git' },
      autoUpdate: true,
    },
  },
}
