# Thand Agent Helm Chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Thand Agent - Open-source agent for AI-ready privilege access management (PAM) and just-in-time access (JIT) to cloud infrastructure, SaaS applications and local systems.

## Installation

### Prerequisites

- Kubernetes 1.19+
- Helm 3.0+

### Add Helm Repository

```bash
helm repo add thand https://helm.thand.io
helm repo update
```

### Install Chart

```bash
# Install with default values
helm install thand-agent thand/agent

# Install with custom values
helm install thand-agent thand/agent -f values.yaml

# Install in a specific namespace
helm install thand-agent thand/agent --namespace thand-system --create-namespace
```

### Uninstall Chart

```bash
helm uninstall thand-agent --namespace thand-system
```

## Configuration

The following table lists the configurable parameters of the Thand Agent chart and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespaceOverride` | Override the namespace | `""` |
| `replicaCount` | Number of replicas | `1` |

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Image repository | `ghcr.io/thand-io/agent` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag (defaults to chart appVersion) | `""` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Service Account

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.automount` | Automount service account token | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name | `""` |

### RBAC

| Parameter | Description | Default |
|-----------|-------------|---------|
| `rbac.create` | Create RBAC resources | `true` |
| `rbac.rules` | ClusterRole rules | See values.yaml |

### Service

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `service.targetPort` | Target port | `http` |
| `service.annotations` | Service annotations | `{}` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.memory` | Memory request | `1Gi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.limits.memory` | Memory limit | `4Gi` |
| `resources.limits.cpu` | CPU limit | `1000m` |

### Autoscaling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU % | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target Memory % | `80` |

### Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.server.port` | Server port | `8080` |
| `config.server.host` | Server host | `0.0.0.0` |
| `config.logging.level` | Log level | `info` |
| `config.logging.format` | Log format | `json` |

### Roles, Providers, and Workflows

| Parameter | Description | Default |
|-----------|-------------|---------|
| `roles.enabled` | Enable roles configuration | `true` |
| `roles.existingSecret` | Use existing secret for roles | `""` |
| `roles.files` | Inline role definitions | `{}` |
| `providers.enabled` | Enable providers configuration | `true` |
| `providers.existingSecret` | Use existing secret for providers | `""` |
| `providers.files` | Inline provider definitions | `{}` |
| `workflows.enabled` | Enable workflows configuration | `true` |
| `workflows.existingSecret` | Use existing secret for workflows | `""` |
| `workflows.files` | Inline workflow definitions | `{}` |

## Examples

### Basic Installation

```bash
helm install thand-agent thand/agent --namespace thand-system --create-namespace
```

### With Custom Configuration

Create a `custom-values.yaml`:

```yaml
replicaCount: 2

image:
  tag: "latest"

resources:
  requests:
    memory: "2Gi"
    cpu: "1000m"
  limits:
    memory: "8Gi"
    cpu: "2000m"

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: thand.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: thand-tls
      hosts:
        - thand.example.com

roles:
  enabled: true
  files:
    all.yaml: |
      roles:
        - name: admin
          description: Administrator role
          permissions: ["*"]

providers:
  enabled: true
  files:
    all.yaml: |
      providers:
        kubernetes-cluster:
          description: Current Kubernetes cluster
          provider: kubernetes
          config: {}
          enabled: true

workflows:
  enabled: true
  files:
    all.yaml: |
      workflows:
        default:
          name: Default Workflow
          steps: []
```

Install with custom values:

```bash
helm install thand-agent thand/agent -f custom-values.yaml --namespace thand-system --create-namespace
```

### Using Existing Secrets

If you want to manage secrets externally:

```bash
# Create secrets first
kubectl create secret generic thand-roles --from-file=all.yaml=./config/roles/all.yaml -n thand-system
kubectl create secret generic thand-providers --from-file=all.yaml=./config/providers/all.yaml -n thand-system
kubectl create secret generic thand-workflows --from-file=all.yaml=./config/workflows/all.yaml -n thand-system
```

Then install with:

```yaml
roles:
  enabled: true
  existingSecret: thand-roles

providers:
  enabled: true
  existingSecret: thand-providers

workflows:
  enabled: true
  existingSecret: thand-workflows
```

## Upgrading

To upgrade an existing release:

```bash
helm upgrade thand-agent thand/agent --namespace thand-system
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n thand-system -l app.kubernetes.io/name=agent
```

### View Logs

```bash
kubectl logs -n thand-system -l app.kubernetes.io/name=agent -f
```

### Describe Deployment

```bash
kubectl describe deployment -n thand-system thand-agent
```

### Check RBAC Permissions

```bash
kubectl get clusterrole,clusterrolebinding -l app.kubernetes.io/name=agent
```

## Links

- [Documentation](https://thand.io)
- [GitHub Repository](https://github.com/thand-io/agent)
- [Issues](https://github.com/thand-io/agent/issues)

## License

BSL-1.1 - See [LICENSE](https://github.com/thand-io/agent/blob/main/LICENSE.md) for more information.
