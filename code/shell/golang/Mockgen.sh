set -e -x
mockgen -destination pkg/mocks/cr-client.go -package mocks sigs.k8s.io/controller-runtime/pkg/client Client
mockgen -destination pkg/mocks/status-writer.go -package mocks sigs.k8s.io/controller-runtime/pkg/client StatusWriter
mockgen -destination pkg/mocks/mockcellowner.go -package mocks orcastack.io/api/pkg/app/v1beta1/common Interface