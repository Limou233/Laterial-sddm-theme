# Agent Instructions

## Scope

- Work only inside this repository unless the user explicitly authorizes another path.
- Preserve user changes and keep unrelated files untouched.
- This project targets KDE Plasma 6, SDDM Qt 6, and Qt Quick 6.

## Release Policy

- Do not run `tools/package.sh` without explicit user approval.
- Do not create, modify, or refresh `release/`, `.tar.gz`, `.zip`, checksum files, or GitHub Releases unless the user explicitly asks in the current task.
- Running the packaging script requires the explicit guard argument:

  ```bash
  bash tools/package.sh --confirm-release
  ```

- `release/` is generated output and must remain ignored by Git.
- Writing source code, running QML validation, and starting `sddm-greeter-qt6 --test-mode` do not count as release generation.

## System Changes

- Do not install or remove packages without explicit user approval.
- Do not modify `/usr/share/sddm/themes`, `/etc/sddm.conf`, `/etc/sddm.conf.d`, or the active SDDM configuration without explicit approval.

## Repository Hygiene

- Keep test code, test screenshots, temporary previews, local wallpapers, and local KCM overrides out of Git.
- Only `assets/default-wallpaper.svg` is an intentionally tracked image asset.
- Do not add generated QML caches, logs, archives, or release directories.
- Keep `theme.conf.user` local and ignored.
- Do not commit secrets, credentials, password values, or machine-specific absolute paths.

## Validation

Allowed checks without release approval:

```bash
qmllint -I /usr/lib64/qt6/qml Main.qml components/*.qml
QT_QPA_PLATFORM=offscreen timeout 5s \
    sddm-greeter-qt6 --test-mode --theme "$PWD"
```

Do not write their outputs into `release/`.

## Git

- Commit only after verifying the working tree and staged file list.
- Do not push unless the user asks or has explicitly authorized publishing changes.
- Keep commit messages concise and imperative.

## License

- Project license: `GPL-3.0-or-later`.
- Preserve the GPL notice and upstream attribution for embedded Material Symbols paths.
