# Local Firebase setup and credential handling

Firebase client API keys are shipped to clients at runtime. Excluding them from
Git is a repository policy, not access control and not a replacement for key
restrictions, Firebase Security Rules, or App Check.

## Set up a fresh clone

1. Install Flutter/FlutterFire and sign in with `firebase login`.
2. Run `flutterfire configure` for the authorized project/platforms to generate
   `lib/firebase_options.dart` and the native Firebase configuration files.
3. Copy `web/firebase-config.example.js` to `web/firebase-config.local.js`, then
   fill its fields from the Firebase console web app configuration. Do not use
   the example placeholders in a running app. The project-owned messaging
   worker loads this ignored file. Keep the two web configurations consistent.
4. Keep the real configuration files local. CI builds must provision them from
   repository/environment secrets before building, including the web local file.
5. Enable the local guard: `git config core.hooksPath .githooks`.
6. Run `python scripts/check_committed_secrets.py --tracked` before pushing.

The hook scans staged content. It never prints credential values. It detects
specific patterns only; it is not a guarantee that every secret is detected.

## Existing published history

This change removes configuration files from the current Git index while
preserving the local copies. Previous commits, forks, PR refs, and other clones
can still contain their prior values. Do not claim this erases Git history.

For a genuine leaked credential, revoke/rotate it at the provider first.
History cleanup is a separate coordinated operation and must preserve the
team's work. Firebase client keys need their API/application restrictions audited;
repository exclusion alone cannot make a shipped client key secret.

References:
- https://firebase.google.com/docs/projects/api-keys
- https://firebase.google.com/support/guides/security-checklist
- https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
