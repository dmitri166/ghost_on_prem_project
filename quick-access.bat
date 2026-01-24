@echo off
echo 🚀 Starting port forwarding for Ghost platform services...
echo.

echo 📝 Ghost Dev (port 2368)...
start "Ghost Dev" cmd /k "kubectl port-forward -n ghost-dev svc/ghost-dev 2368:2368"

echo 📝 Ghost Staging (port 2369)...
start "Ghost Staging" cmd /k "kubectl port-forward -n ghost-staging svc/ghost-staging 2369:2368"

echo 📝 Ghost Production (port 2370)...
start "Ghost Production" cmd /k "kubectl port-forward -n ghost-prod svc/ghost-prod 2370:2368"

echo 📈 Grafana (port 3000)...
start "Grafana" cmd /k "kubectl port-forward -n monitoring-new svc/monitoring-stack-grafana 3000:3000"

echo 🔍 Prometheus (port 9090)...
start "Prometheus" cmd /k "kubectl port-forward -n monitoring-new svc/monitoring-stack-kube-prometheus 9090:9090"

echo 🚀 ArgoCD (port 8080)...
start "ArgoCD" cmd /k "kubectl port-forward -n argocd svc/argocd-server 8080:80"

echo.
echo ✅ Port forwarding started in separate windows!
echo.
echo 🌐 Access URLs:
echo 📝 Ghost Dev: http://localhost:2368/
echo 📝 Ghost Staging: http://localhost:2369/
echo 📝 Ghost Production: http://localhost:2370/
echo 📈 Grafana: http://localhost:3000/ (admin/admin123)
echo 🔍 Prometheus: http://localhost:9090/
echo 🚀 ArgoCD: http://localhost:8080/
echo.
echo Close the individual windows to stop each service.
pause
