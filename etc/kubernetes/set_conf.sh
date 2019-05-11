export KUBE_APISERVER="https://192.168.50.116:6443"
export KUBE_CERT_HOME="/etc/kubernetes/ssl"
export KUBE_CLUSTER_NAME="k8s"

# setup token
export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')

cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

#setup kubelet bootstrap kubeconfig.

kubectl config set-cluster ${KUBE_CLUSTER_NAME}  \
  --certificate-authority=${KUBE_CERT_HOME}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig


kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig


kubectl config set-context default \
  --cluster=${KUBE_CLUSTER_NAME} \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig

kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

#setup kube-proxy kubeconfig.

kubectl config set-cluster ${KUBE_CLUSTER_NAME} \
  --certificate-authority=${KUBE_CERT_HOME}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig
  



kubectl config set-credentials kube-proxy \
  --client-certificate=${KUBE_CERT_HOME}/kube-proxy.pem \
  --client-key=${KUBE_CERT_HOME}/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig


kubectl config set-context default \
  --cluster=${KUBE_CLUSTER_NAME} \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig


kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


# setup kubectl kubeconfig.

kubectl config set-cluster ${KUBE_CLUSTER_NAME} \
  --certificate-authority=${KUBE_CERT_HOME}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER}

kubectl config set-credentials admin \
  --client-certificate=${KUBE_CERT_HOME}/admin.pem \
  --embed-certs=true \
  --client-key=${KUBE_CERT_HOME}/admin-key.pem

kubectl config set-context kubernetes \
  --cluster=${KUBE_CLUSTER_NAME} \
  --user=admin

kubectl config use-context kubernetes
