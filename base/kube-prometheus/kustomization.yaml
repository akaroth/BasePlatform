
resources:
  - namespace.yaml
  - output.yaml

patches:
  - target:
      kind: ServiceMonitor
      name: prometheus-kube-prometheus
      namespace: monitoring
    patch: |-
      apiVersion: monitoring.coreos.com/v1
      kind: ServiceMonitor
      metadata:
        name: prometheus-kube-prometheus
        namespace: monitoring
        annotations:
          argocd.argoproj.io/hook: PreSync
  - target:
      kind: Alertmanager
      name: prometheus-kube-prometheus-alertmanager
      namespace: monitoring
    patch: |-
      apiVersion: monitoring.coreos.com/v1
      kind: ServiceMonitor
      metadata:
        name: prometheus-kube-prometheus-alertmanager
        namespace: monitoring
        annotations:
          argocd.argoproj.io/hook: PreSync
