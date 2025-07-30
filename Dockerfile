FROM registry.ci.openshift.org/ocp/builder:rhel-9-golang-1.24-openshift-4.20 AS builder
WORKDIR /go/src/github.com/openshift/cluster-storage-operator
COPY . .
RUN make && \
    mkdir -p /tmp/build && \
    cp /go/src/github.com/openshift/cluster-storage-operator/bin/cluster-storage-operator-tests-ext /tmp/build/cluster-storage-operator-tests-ext && \
    gzip /tmp/build/cluster-storage-operator-tests-ext

FROM registry.ci.openshift.org/ocp/4.20:base-rhel9
COPY --from=builder /go/src/github.com/openshift/cluster-storage-operator/cluster-storage-operator /usr/bin/
COPY --from=builder /tmp/build/cluster-storage-operator-tests-ext.gz /usr/bin/
COPY manifests /manifests
ENTRYPOINT ["/usr/bin/cluster-storage-operator"]
LABEL io.openshift.release.operator true
LABEL io.k8s.display-name="OpenShift Cluster Storage Operator" \
      io.k8s.description="The cluster-storage-operator installs and maintains the storage components of OCP cluster." \
      io.openshift.tags="openshift,tests,e2e,e2e-extension"
