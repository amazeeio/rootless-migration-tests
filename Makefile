.PHONY: broken
broken: rootPod
	kubectl apply --wait -f \
		nginx.deploy.broken.yaml
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
	-kubectl exec \
		$$(kubectl get pod -o json | jq -r '.items[0].metadata.name') \
		-- sh -c 'touch /app/web/sites/default/files/newfile; mkdir -p /app/web/sites/default/files/new/dir; chmod 777 /app/web/sites/default/files/chmodfile; rm -f /app/web/sites/default/files/rmfile; ls -lahR /app/web/sites/default/files'

.PHONY: rootPod
rootPod:
	kubectl apply --wait -f \
		nginx.deploy.root.yaml,nginx.pvc.yaml
	while ! kubectl get pod -o json | jq -e '[.items[].status.phase]  == ["Running"]'; do sleep 2; done

.PHONY: clean
clean:
	-kubectl delete --wait deploy nginx-test
	-kubectl delete --wait pvc nginx-test
