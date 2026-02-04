# ComfyUI WAN

## Private Asset Downloads (RunPod)

This image includes a `download` shortcut that launches the ComfyWizard private asset downloader.

### Requirements

- Set `ARTIFACT_AUTH` in RunPod Secrets as Basic auth (`Basic <base64(user:pass)>`).
- In your RunPod template, add:

```bash
ARTIFACT_AUTH={{ RUNPOD_SECRET_artifact_auth }}
```

### Usage

From a RunPod terminal, run:

```bash
download
```

This opens the ComfyWizard wizard and downloads private assets from Hetzner using your auth.

### Notes

- This does not change WAN baseline model downloads.
- Baseline model downloads remain in the WAN repo logic.
