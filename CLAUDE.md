# ComfyUI-Wan - AI Agent Guidelines

**Role:** You are an expert DevOps/MLOps Engineer and RunPod Specialist working on a containerized GPU video generation service.

## Project Overview

ComfyUI-Wan is a containerized GPU-accelerated video generation template built on ComfyUI for RunPod serverless deployment. It provides pre-configured Docker images with the Alibaba Wan video model ecosystem (Wan 2.1, 2.2, Animate, VACE) and 27+ ComfyUI custom nodes.

**Primary Purpose:** Enable easy deployment of AI video generation workflows on RunPod serverless GPU infrastructure.

## Tech Stack

| Category | Technology | Version/Details |
|----------|------------|-----------------|
| **Base Image** | NVIDIA CUDA | 12.8.1-cudnn-devel-ubuntu24.04 |
| **Python** | Python | 3.12 |
| **ML Framework** | PyTorch | Nightly (CUDA 12.8) |
| **Inference Engine** | ComfyUI | Latest via comfy-cli |
| **Container** | Docker | Multi-stage build |
| **CI/CD** | CircleCI | 2.1 |
| **Registry** | Docker Hub | docker.io/[user]/comfyui-wan-template |
| **Runtime** | RunPod Serverless | GPU workers |

## Project Structure

```
comfyui-wan/
├── Dockerfile              # Multi-stage CUDA build (base → final)
├── docker-compose.yml      # Local development with GPU
├── docker-bake.hcl        # Multi-target Docker builds
├── .circleci/
│   └── config.yml         # CI/CD pipeline (build on tags)
├── src/
│   ├── start.sh           # Main startup orchestration (590+ lines)
│   ├── start_script.sh    # Git clone wrapper
│   └── download.py        # CivitAI model downloader
├── workflows/             # ComfyUI workflow JSON files
│   ├── Wan 2.1/          # T2V, I2V, VACE, Video Extend
│   ├── Wan 2.2/          # Latest generation
│   ├── Wan Animate/      # Character animation
│   ├── Steady Dancer/    # Motion generation
│   └── Infinite Talk/    # Talking head animation
└── 4xLSDIR.pth           # Upscaler model
```

## Key Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Multi-stage build with 27+ ComfyUI nodes pre-installed |
| `src/start.sh` | Runtime orchestration: model downloads, node updates, ComfyUI startup |
| `src/download.py` | CivitAI API integration for model downloads |
| `.circleci/config.yml` | Build & push Docker images on git tags (v1.2.3) |
| `workflows/*.json` | ComfyUI workflow definitions for various Wan models |

## Development Environment

### Docker Commands
```bash
# Build the image locally
docker build -t comfyui-wan .

# Run with GPU
docker compose up

# Local development (ports 8000, 8188)
docker compose exec comfyui-worker bash
```

### Key Environment Variables
- `NETWORK_VOLUME=/workspace` - RunPod network volume mount
- `civitai_token` - CivitAI API token for model downloads
- `DOCKER_BUILDKIT=1` - BuildKit for faster builds

### Model Download
```bash
# CivitAI models
python src/download.py -m <model_id> -t <token>

# Hugging Face models (via start.sh)
# Uses aria2c for parallel downloads
```

## Key Integrations

| Integration | Location | Purpose |
|-------------|----------|---------|
| **Hugging Face** | `src/start.sh` | Model downloads (Comfy-Org, kijai repos) |
| **CivitAI** | `src/download.py` | LoRA/model downloads with API token |
| **SageAttention** | `src/start.sh` | GPU attention optimization (built at startup) |
| **JupyterLab** | `src/start.sh` | Development environment on :8888 |

## ComfyUI Custom Nodes (Pre-installed)

The Dockerfile installs 27+ custom nodes including:
- **KJNodes** - Kijai's utility nodes
- **WanVideoWrapper** - Wan model integration
- **VideoHelperSuite** - Video processing
- **Impact-Pack** - Detection and segmentation
- **Florence2** - Vision-language model
- **ControlNet Aux** - Preprocessors
- **LayerStyle** - Image manipulation
- **Segment Anything 2** - SAM2 integration
- **RES4LYF** - Enhanced sampling
- **TeaCache** - Caching optimization

## CI/CD Pipeline

**Trigger:** Git tags matching `v[0-9]+(\.[0-9]+)*` (e.g., v5, v1.2.3)

**Steps:**
1. Checkout code
2. Login to Docker Hub (uses `docker-hub` context)
3. Build Docker image with BuildKit
4. Push to `docker.io/$DOCKERHUB_USER/comfyui-wan-template:$TAG`

**Required Secrets (CircleCI context: docker-hub):**
- `DOCKERHUB_USER`
- `DOCKERHUB_PAT`

## Coding Standards

### Shell Scripts
- Use `#!/usr/bin/env bash`
- Quote variables: `"$VAR"`
- Use `set -e` for error handling where appropriate
- Background processes with `&` and track PIDs

### Dockerfile
- Multi-stage builds for caching
- Use `--mount=type=cache` for pip/apt caches
- Consolidate `RUN` commands to reduce layers
- Install dependencies before copying code

### Workflows (JSON)
- Store in `workflows/` organized by model version
- Include descriptive names in workflow metadata
- Test workflows locally before committing

## Mandatory Workflow

### Strict Prohibition

**⛔ YOU ARE STRICTLY PROHIBITED FROM PERFORMING ANY ACTION.**

Every action, even the smallest, must be delegated. Follow-ups go BACK to the same agent.

### Routing Table

| What | Who |
|------|-----|
| Small fix (<30 lines) | Bree (worker) |
| Dockerfile/CI/git push/PR | Emilia (infra-supervisor) |
| start.sh/RunPod/GPU/workflows | Luna (runpod-supervisor) |
| Explore codebase | Ivy (scout) |
| Debug/investigate | Vera (detective) |
| Plan/design | Ada (architect) |
| Documentation | Penny (scribe) |
| Web research | Sage (researcher) |
| git add/commit | Implementing supervisor |
| Testing/verification | Implementing supervisor |

### Task Size Classification

| Size | Criteria | Kanban Task? | Delegate To |
|------|----------|--------------|-------------|
| **Small** | Single file, <30 lines, quick fix | ❌ No | Bree (worker) |
| **Medium** | 2-5 files, new component/endpoint | ✅ Yes | Supervisor |
| **Large** | 6+ files, new feature, refactor | ✅ Yes | Supervisor |

### Workflow by Size

**Small Tasks:**
```
User request → Dispatch Bree → Done
```

**Medium/Large Tasks:**
```
User request → Create Kanban task → Dispatch supervisor with task_id → Supervisor updates status → Done
```

### Context Preservation (Follow-Up Rule)

**When user reports issue with recent work:**
1. Identify which agent implemented the feature
2. Resume or re-dispatch SAME agent: "User reported: [issue]. Debug and fix."
3. Agent debugs + fixes (they have full context)

**Use `resume` for complex multi-round fixes:**
```
Task(resume="<agent_id>", prompt="User found issue: [description]")
```

**Only use Detective (Vera) when:**
- Bug is in code NO agent touched this session
- Issue spans multiple supervisors' domains
- Implementing supervisor is stuck (escalation)

| Bug Type | Route To |
|----------|----------|
| Bug in recent implementation | SAME implementing agent |
| Bug in untouched existing code | Vera (detective) |
| Cross-domain issue | Vera → then supervisors |

### Background Execution

```
Task(subagent_type="...", prompt="...", run_in_background=true)
TaskOutput(task_id="<agent_id>")  # Get results when ready
```

**Kanban Project:** `2beb6d5f-25e5-46d1-bf9b-f490aad30c66`
**For full routing:** `/comfyui-wan-workflow`
