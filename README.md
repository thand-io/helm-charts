# Thand Helm Charts

[![Release Charts](https://github.com/thand-io/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/thand-io/helm-charts/actions/workflows/release.yml)

This repository contains Helm charts for deploying Thand components to Kubernetes.

## Usage

### Add Helm Repository

```bash
helm repo add thand https://helm.thand.io
helm repo update
```

### Install Chart

```bash
helm install thand-agent thand/agent --namespace thand-system --create-namespace
```

## Available Charts

### Thand Agent

The Thand Agent is an open-source agent for AI-ready privilege access management (PAM) and just-in-time access (JIT) to cloud infrastructure, SaaS applications and local systems.

**Chart Repository:** `thand/agent`

**Documentation:** [charts/agent/README.md](charts/agent/README.md)

**Quick Install:**
```bash
helm install thand-agent thand/agent -n thand-system --create-namespace
```

## Development

### Local Testing

```bash
# Lint chart
helm lint charts/agent

# Template chart (dry-run)
helm template thand-agent charts/agent

# Install chart locally
helm install thand-agent charts/agent --namespace thand-system --create-namespace --dry-run --debug
```

### Package Chart

```bash
helm package charts/agent
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](https://github.com/thand-io/agent/blob/main/CONTRIBUTING.md) for details.

## License

BSL-1.1 - See [LICENSE](https://github.com/thand-io/agent/blob/main/LICENSE.md) for more information.

## Links

- [Thand Documentation](https://thand.io)
- [Thand Agent Repository](https://github.com/thand-io/agent)
- [Report Issues](https://github.com/thand-io/agent/issues)
