# lada

This repository contains a small derived Docker image based on `ladaapp/lada:latest`.

The image is adjusted for running LADA in Slurm HPC environments where ordinary users launch containers through Singularity/Apptainer. In that setup, user identity passthrough can make tools installed under the original container user's home directory unavailable or inconvenient to execute. This image moves the Python site-packages and command-line entry points from `/home/lada/.local` into system-level locations under `/usr/local`, then makes them readable and executable for non-root users.

## What changed

- Moves LADA Python packages from `/home/lada/.local/lib/.../site-packages` to `/usr/local/lib/.../site-packages`.
- Moves LADA executables from `/home/lada/.local/bin` to `/usr/local/bin`.
- Rewrites the `lada` and `lada-cli` shebangs to use `/usr/local/bin/python3`.
- Makes `/usr/local/lib` and `/usr/local/bin` readable/executable by ordinary users.
- Sets model weight environment variables for predictable model discovery:`LADA_MODEL_WEIGHTS_DIR=/model_weights`


## Why this exists

The upstream image works well as a Docker image, but HPC clusters commonly run OCI images through Singularity/Apptainer under the submitting user's UID/GID. This can expose user passthrough issues when application files are installed under a container-specific home directory such as `/home/lada/.local`.

By relocating the installed packages and CLI entry points to `/usr/local`, the image is easier to use from Slurm jobs launched by regular cluster users without depending on the original `lada` container user.

## Image

The GitHub Actions workflow builds and publishes the image to GHCR:

```text
ghcr.io/will-023/lada:latest
```

Other tags may be published for branches, commits, and version tags.

## Docker usage

```bash
docker run --rm ghcr.io/will-023/lada:latest --help
```

If model weights are stored on the host, mount them into `/model_weights`:

```bash
docker run --rm \
  -v /path/to/model_weights:/model_weights:ro \
  ghcr.io/will-023/lada:latest --help
```

## Singularity / Apptainer usage

Pull the image:

```bash
apptainer pull lada.sif docker://ghcr.io/will-023/lada:latest
```

Run it:

```bash
apptainer run lada.sif --help
```

With model weights mounted from the host:

```bash
apptainer run \
  --bind /path/to/model_weights:/model_weights:ro \
  lada.sif --help
```

## Slurm example

```bash
#!/bin/bash
#SBATCH --job-name=lada
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00

apptainer run --nv \
  lada.sif --help
```

Adjust the command arguments and resource requests for the actual LADA workload.

## Notes

This repository contains only the Dockerfile and build workflow for the derived image. The upstream LADA project and base image remain under their original licenses and terms.
