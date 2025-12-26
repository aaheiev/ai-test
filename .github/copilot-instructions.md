# AI Coding Agent Instructions

## Project Overview
This project provides utilities for analyzing Kubernetes cluster state exported from a running cluster. The primary data source is `pods.json`, a complete Kubernetes v1 API response containing Pod objects from multiple namespaces (e.g., ArgoCD).

**Current State**: The project is in early development. Ruby-based utilities are being built to transform the raw Kubernetes export into processed analysis.

## Architecture & Key Components
- **pods.json**: Real Kubernetes cluster state (~64K lines); contains Pod metadata, specs, status, and controller references (StatefulSets, Deployments). Generated via `kubectl get pods -A -o json > pods.json`.
- **Future scripts**: Will be written in Ruby to parse and analyze pod data.

## Key Data Patterns in pods.json
The JSON follows Kubernetes API v1 structure:
- Root object has `apiVersion: "v1"` and `items[]` array
- Each Pod object contains:
  - `metadata`: namespace, name, labels (e.g., `app.kubernetes.io/name`), annotations, timestamps, ownerReferences
  - `spec`: containers[], volumes[], service account, affinity rules
  - `status`: phase (Running/Pending/Failed), conditions, container statuses

### Important Fields for Filtering
- `pod['metadata']['namespace']` — e.g., "argocd", "kube-system"
- `pod['metadata']['labels']['app.kubernetes.io/name']` — application identifier (keys with dots are literal strings)
- `pod['metadata']['ownerReferences']` — array indicating parent controller type and name
- `pod['spec']['containers']` — container definitions with args, env, resources
- `pod['status']['phase']` — operational state of the pod

## Ruby Code Patterns
```ruby
require 'json'

data = JSON.parse(File.read('pods.json'))

# Iterate all pods
data['items'].each do |pod|
  namespace = pod['metadata']['namespace']
  name = pod['metadata']['name']
  labels = pod['metadata']['labels']
  phase = pod['status']['phase']
  
  # Access owner reference (if exists)
  owner = pod['metadata']['ownerReferences']&.first
  owner_kind = owner&.fetch('kind')  # StatefulSet, Deployment, etc.
end

# Filter patterns
argocd_pods = data['items'].select { |p| p['metadata']['namespace'] == 'argocd' }
statefulset_pods = data['items'].select { |p| p['metadata']['ownerReferences']&.any? { |o| o['kind'] == 'StatefulSet' } }
```

## Development Considerations
- The `pods.json` file is large; scripts should use filtering and streaming where performance matters
- Labels follow Kubernetes conventions (`app.kubernetes.io/*`, `kubernetes.io/*`); use these for querying
- Status fields include conditions array with timestamps and reasons — useful for pod lifecycle analysis
- Use `.fetch()` with default values when accessing optional nested fields to avoid nil errors
