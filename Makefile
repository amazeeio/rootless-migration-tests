.PHONY: broken1
broken1: rootPod
	kubectl apply --wait -f \
		nginx.deploy.broken1.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done
	kubectl logs --all-containers --prefix --tail=64 \
		-l app.kubernetes.io/instance=nginx

.PHONY: broken2
broken2: rootPod
	kubectl apply --wait -f \
		nginx.deploy.broken2.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done
	kubectl logs --all-containers --prefix --tail=64 \
		-l app.kubernetes.io/instance=nginx

.PHONY: broken3
broken3: rootPod
	kubectl apply --wait -f \
		nginx.deploy.broken3.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done
	kubectl logs --all-containers --prefix --tail=64 \
		-l app.kubernetes.io/instance=nginx

.PHONY: rootless
rootless:
	kubectl apply --wait -f \
		nginx.deploy.rootless.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done
	kubectl logs --prefix --tail=64 \
		-l app.kubernetes.io/instance=nginx \
		-c fix-storage-permissions
	kubectl exec -it \
		$$(kubectl get pod -o json | jq -r '.items[0].metadata.name') \
		-- sh -c 'touch /app/web/sites/default/files/newfile; chmod 777 /app/web/sites/default/files/chmodfile'
	kubectl exec -it \
		$$(kubectl get pod -o json | jq -r '.items[0].metadata.name') \
		-- sh -c 'touch /app/web/sites/default/files/newfile; ls -lahR /app/web/sites/default/files/'

.PHONY: rootPod
rootPod:
	kubectl apply --wait -f \
		nginx.deploy.root.yaml,nginx.pvc.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done

.PHONY: clean
clean:
	-kubectl delete --wait deploy nginx-test
	-kubectl delete --wait pvc nginx-test
