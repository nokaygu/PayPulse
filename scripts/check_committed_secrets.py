"""Scan staged files by default; --tracked scans the checked-out tracked files."""
from pathlib import Path
import re
import subprocess
import sys

PATTERNS = {
    'Google API key': rb'AIza[0-9A-Za-z_-]{35}',
    'private key': rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    'GitHub token': rb'(?:ghp_|github_pat_)[A-Za-z0-9_]{20,}',
    'OpenAI key': rb'sk-(?:proj-|svcacct-)[A-Za-z0-9_-]{20,}',
    'Stripe secret': rb'sk_(?:live|test)_[A-Za-z0-9]{16,}',
    'AWS access ID': rb'(?:AKIA|ASIA)[A-Z0-9]{16}',
    'Google OAuth secret': rb'GOCSPX-[A-Za-z0-9_-]{20,}',
}
BLOCKED_CONFIGS = {
    'lib/firebase_options.dart',
    'android/app/google-services.json',
    'ios/Runner/GoogleService-Info.plist',
    'macos/Runner/GoogleService-Info.plist',
    'web/firebase-config.local.js',
}

def git(*args):
    return subprocess.run(['git', *args], check=True, capture_output=True).stdout

def main():
    tracked = '--tracked' in sys.argv
    args = ('ls-files', '-z') if tracked else (
        'diff', '--cached', '--name-only', '--diff-filter=ACMRT', '-z')
    paths = git(*args).split(b'\0')
    findings = []
    for raw in paths:
        if not raw:
            continue
        path = raw.decode('utf-8', errors='surrogateescape')
        if path in BLOCKED_CONFIGS:
            findings.append((path, 'local configuration must not be tracked'))
        if tracked:
            file = Path(path)
            if file.is_symlink() or not file.is_file():
                continue
            data = file.read_bytes()
        else:
            data = git('show', ':' + path)
        for label, pattern in PATTERNS.items():
            if re.search(pattern, data):
                findings.append((path, label))
    for path, label in findings:
        print(f'BLOCKED: {path!r}: {label}; value hidden')
    if findings:
        return 1
    print('Secret scan passed. No configured secret patterns found.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
