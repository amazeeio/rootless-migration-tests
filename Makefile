.PHONY: broken1
broken1: rootPod
	kubectl apply --wait -f \
		nginx.deploy.broken1.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done
	kubectl logs --all-containers --prefix --tail=64 \
		-l app.kubernetes.io/instance=nginx

.PHONY: rootless
rootless:
	kubectl apply --wait -f \
		nginx.deploy.rootless.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done
	kubectl logs --all-containers --prefix --tail=64 \
		-l app.kubernetes.io/instance=nginx
	kubectl exec -it \
		$$(kubectl get pod -o json | jq -r '.items[0].metadata.name')
		-- ls -lahR

.PHONY: rootPod
rootPod:
	kubectl apply --wait -f \
		nginx.deploy.root.yaml,nginx.pvc.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done

.PHONY: clean
clean:
	kubectl delete --wait deploy nginx-test
	kubectl delete --wait pvc nginx-test
