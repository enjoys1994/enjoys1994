package main

import (
	"context"
	"fmt"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

type Config struct {
	Host  string
	Token string
	Port  int
}

func main() {

	clientSet, _ := NewKubernetesClient(&Config{
		Host:  "10.20.144.29",
		Port:  6443,
		Token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IlEwQlY3TXZ4RkZGZzhGbFJvdDJYUTIzeS1JclJMS1lKcWpjNUwyTzBCMlUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJvcmNhLWNvbXBvbmVudHMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoib2Mtc2VlLWltcG9ydC0yOS1jb21wb25lLTQ3ZTMxLXRva2VuLWJ6YmtiIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Im9jLXNlZS1pbXBvcnQtMjktY29tcG9uZS00N2UzMSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6Ijg2ZDY1MGY0LTgwZWQtNDFhYi1iMjkyLWFmMTZlZGI2NDA3NyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpvcmNhLWNvbXBvbmVudHM6b2Mtc2VlLWltcG9ydC0yOS1jb21wb25lLTQ3ZTMxIn0.m_RWvZhzILUstufuX-dUGAqj-vj5cnSZzbv2b2XcNyKWNcdDgbXS5j1JHNR5R_0oTgaSe20_C65ddEadNPwSMK9nYi6zBAR78eYJEjCA3DsXsgYLkWroCF_97dZ9i5nMNjGc8ndQ2hnbGI_7Or0zywXsRSGg62YHbQIgORfQEBWt079TN47ByDyvfRofGjt7oyPlfmRQYNFFTp2Z14wNRqa_3HtF2rAPBp2XY8-is641TweV2mAu7AhxYjNrk4_m9xSKi7z1YZuMX4KRtrAGy9C6rI3XICI9uXy3TfUzHDZ2yEO-enpl6j5gR3yXjOthH0yO1UWJK7ruEGZcblA6KA",
	})

	namespaceList, err := clientSet.CoreV1().Namespaces().List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		log.Log.Info(err.Error())
	}
	//namespaces:=GetAllNamespace(clientset)
	var namespaces []string
	fmt.Println("******************")

	for _, nsList := range namespaceList.Items {
		fmt.Println(nsList.Name)
		namespaces = append(namespaces, nsList.Name)
	}

	fmt.Println("******************")

}

func NewKubernetesClient(c *Config) (*kubernetes.Clientset, error) {
	kubeConf := &rest.Config{
		Host:        fmt.Sprintf("%s:%d", c.Host, c.Port),
		BearerToken: c.Token,
		TLSClientConfig: rest.TLSClientConfig{
			Insecure: true,
		},
	}
	return kubernetes.NewForConfig(kubeConf)
}

// GetAllNamespace get all namespace in cluster.
func GetAllNamespace(clientset *kubernetes.Clientset) []string {
	var namespaces []string
	namespaceList, err := clientset.CoreV1().Namespaces().List(context.TODO(), metav1.ListOptions{})

	if err != nil {
		log.Log.Info("***************err*****************")
		log.Log.Info(err.Error())
	} else {
		//fmt.Printf(namespaces[0])
		for _, nsList := range namespaceList.Items {
			namespaces = append(namespaces, nsList.Name)
		}
	}

	return namespaces
}
