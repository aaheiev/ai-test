# AI Coding Agent Instructions

## Project Overview
This is a Kubernetes Pod data parsing utility written in Ruby. The project transforms a Kubernetes cluster export (`pods.json`) into processed output. The `pods.json` file contains a complete Kubernetes v1 API response with Pod objects from multiple namespaces (e.g., ArgoCD).

## Architecture & Key Components
- **parse.rb**: Main Ruby script (currently minimal - intended as entry point for pod data processing)
- **pods.json**: Real Kubernetes cluster state (~64K lines); contains Pod metadata, specs, status, and controller references (StatefulSets, Deployments)

## Development Workflow
- **Language**: Ruby (#!/usr/bin/env ruby shebang for executability)
- **Dependencies**: JSON library (built-in)
- **Data Format**: Kubernetes API v1 JSON structure with `apiVersion`, `kind`, `metadata`, `spec`, `status` fields

## Working with pods.json
The JSON structure mirrors Kubernetes API:
- `items[]`: Array of Pod objects
- Each Pod contains: `metadata` (labels, annotations, timestamps), `spec` (containers, volumes), `ownerReferences` (StatefulSet/Deployment linkage)
- Typical fields for filtering: `metadata.namespace`, `metadata.labels`, `spec.containers[]`, `ownerReferences[].kind`

## Code Patterns
- Use `JSON.parse(File.read('pods.json'))` to load data
- Iterate `data['items']` to process individual pods
- Access nested metadata: `pod['metadata']['labels']['app.kubernetes.io/name']` (note: keys with dots are literal)
- Filter by `metadata.namespace` (example: 'argocd') or `ownerReferences[].kind` (StatefulSet, Deployment)

## Key Considerations
- Pod JSON can be very large; consider streaming or filtering strategies
- Label selectors and field selectors are common query patterns in Kubernetes
- Pod lifecycle: focus on `status.phase` and `status.conditions` for operational state
