# Security Policy

## Supported versions

ThinkingOrbsKit has not published its first remote release. Security fixes currently
target the latest commit on `main`.

## Report a vulnerability

Do not disclose a suspected vulnerability in a public issue. Contact the repository
owner through a private channel and include:

- the affected revision;
- reproduction steps or a proof of concept;
- expected impact; and
- any suggested mitigation.

Do not include live credentials or personal data. Replace them with clearly marked
placeholders.

## Security boundary

The package performs deterministic in-memory geometry and SwiftUI rendering. It has
no networking, persistence, authentication, analytics, runtime code loading, or
third-party package dependencies. The demo requests no sensitive device permissions.

Repository automation scans the working tree and git history for high-confidence
credential formats. This is a guardrail, not a replacement for review or professional
security testing when the package is embedded in a larger application.
