# packer

### Usage

1. Build, start and SSH to the VM using provided [Makefile](Makefile).

2. Enroll to Intune: `intune-portal &`
    * If not compliant: `rm -f "/run/intune/$(id -u)/pwquality"` and refresh

3. Login to ZScaler: `/opt/zscaler/bin/ZSTray &`
    * Get the token from browser: `/opt/zscaler/scripts/zstray_desktop.sh "zsa://token?zpatoken=xxx"`

### Tips

If you ever get asked about some keyring password, it's just `xxx` - see [install.pkr.hcl](install.pkr.hcl).
