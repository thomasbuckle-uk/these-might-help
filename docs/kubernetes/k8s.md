# Kubernetes

## Commands

---
### Basic pod management commands
`kubectl get pods` - list pods (add `-w` to use always watch)

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

`kubectl get pods -l "app=firstapp" --show-labels` - show labels for all pods with app=firstapp

---

### Node selectors

By using Node Selector we can choose which pod will run on which node

```#yaml
  nodeSelector:
    hddtype: ssd
```
`kubectl label nodes app1 hddtype=ssd` - add label `hddtype=ssd` to app1 node (imperative)

---
### Annotation

Similar to labels, but they are used to store information that is not meant to be seen by the user.

```#yaml
  annotations:
    description: "This is a description"
```
`kubectl annotate pods annotationpod foo=bar` - imperative way