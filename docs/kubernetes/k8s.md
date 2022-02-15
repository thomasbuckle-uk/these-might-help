# Kubernetes

## Commands

---
### Basic pod management commands
`kubectl get pods` - list pods

`kubectl describe pods {podname}` - show pod details

`kubectl apply -f {podname}.yaml` - create pod from yaml file

`kubectl delete -f {podname}.yaml` - delete pod from yaml file

---
### Labels
`kubectl label pods pod1 team=development`  - adding label team=development on pod1

`kubectl get pods` - show-labels

`kubectl label pods pod1 team` -  remove team (key:value) from pod1

`kubectl label --overwrite pods pod1 team=test` - overwrite/change label on pod1

`kubectl label pods --all foo=bar`  - add label foo=bar for all pods