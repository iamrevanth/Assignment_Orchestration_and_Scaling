#!/bin/bash
PLAIN_IP="65.0.139.200"

echo "🔍 Verifying Helm Deployment"
helm list

echo "🔍 Verifying Kubernetes Pods and Services"
minikube kubectl -- get all

echo "⏳ Waiting for Backend pod to be Ready..."
timeout=90
while [ "$timeout" -gt 0 ]; do
  status=$(kubectl get pods -l app.kubernetes.io/name=backend -o jsonpath="{.items[0].status.containerStatuses[0].ready}" 2>/dev/null)
  if [ "$status" = "true" ]; then
    echo "✅ Backend pod is Ready"
    pkill -f "kubectl port-forward svc/backend" || true
    sleep 2
    echo "🌐 Starting port-forward: Backend (3101 → 3001)..."
    daemonize -o /home/ubuntu/backend.log -e /home/ubuntu/backend.err \
      /usr/local/bin/kubectl port-forward svc/backend 3101:3001 --address=0.0.0.0
    sleep 5
    echo "✅ Backend accessible at: http://$PLAIN_IP:3101"
    break
  fi
  echo "⏳ Still waiting for backend... ($timeout seconds left)"
  sleep 5
  timeout=$((timeout - 5))
done

echo "⏳ Waiting for Frontend pod to be Ready..."
timeout=90
while [ "$timeout" -gt 0 ]; do
  status=$(kubectl get pods -l app.kubernetes.io/name=frontend -o jsonpath="{.items[0].status.containerStatuses[0].ready}" 2>/dev/null)
  if [ "$status" = "true" ]; then
    echo "✅ Frontend pod is Ready"
    pkill -f "kubectl port-forward svc/frontend" || true
    sleep 2
    echo "🌐 Starting port-forward: Frontend (3100 → 3000)..."
    daemonize -o /home/ubuntu/frontend.log -e /home/ubuntu/frontend.err \
      /usr/local/bin/kubectl port-forward svc/frontend 3100:3000 --address=0.0.0.0
    sleep 5
    echo "✅ Frontend accessible at: http://$PLAIN_IP:3100"
    break
  fi
  echo "⏳ Still waiting for frontend... ($timeout seconds left)"
  sleep 5
  timeout=$((timeout - 5))
done

# echo "🌐 Access URL for Frontend:"
# frontend_url=$(minikube service frontend --url)
# echo "✅ Frontend running at: $frontend_url"

# echo "🌐 Access URL for Backend:"
# backend_url=$(minikube service backend --url)
# echo "✅ Backend running at: $backend_url"

