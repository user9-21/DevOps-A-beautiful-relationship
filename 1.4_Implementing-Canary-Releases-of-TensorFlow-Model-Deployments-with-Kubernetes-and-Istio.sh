BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}

Starting Execution 

${RESET}"
#gcloud auth list
#gcloud config list project
export PROJECT_ID=$(gcloud info --format='value(config.project)')
#export BUCKET_NAME=$(gcloud info --format='value(config.project)')
#export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
export ZONE=us-central1-a



#USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#

cd
SRC_REPO=https://github.com/GoogleCloudPlatform/mlops-on-gcp
kpt pkg get $SRC_REPO/workshops/mlep-qwiklabs/tfserving-canary-gke tfserving-canary
cd tfserving-canary
gcloud config set compute/zone us-central1-f
PROJECT_ID=$(gcloud config get-value project)
CLUSTER_NAME=cluster-1
gcloud beta container clusters create $CLUSTER_NAME \
  --project=$PROJECT_ID \
  --addons=Istio \
  --istio-config=auth=MTLS_PERMISSIVE \
  --cluster-version=latest \
  --machine-type=n1-standard-4 \
  --num-nodes=3
  
gcloud container clusters get-credentials $CLUSTER_NAME
kubectl get service -n istio-system
kubectl get pods -n istio-system
kubectl label namespace default istio-injection=enabled


echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"


export MODEL_BUCKET=${PROJECT_ID}-bucket
gsutil mb gs://${MODEL_BUCKET}
gsutil cp -r gs://workshop-datasets/models/resnet_101 gs://${MODEL_BUCKET}
gsutil cp -r gs://workshop-datasets/models/resnet_50 gs://${MODEL_BUCKET}


echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

echo $MODEL_BUCKET
sed -i "s/YOUR_BUCKET/$MODEL_BUCKET/g" tf-serving/configmap-resnet50.yaml 
cat tf-serving/configmap-resnet50.yaml 
kubectl apply -f tf-serving/configmap-resnet50.yaml
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"
cat tf-serving/deployment-resnet50.yaml
kubectl apply -f tf-serving/deployment-resnet50.yaml
kubectl get deployments | grep 'image-classifier-resnet50' |  awk '{print $4}' 
DEPLOYMENT_STATE=$(kubectl get deployments | grep image-classifier-resnet50 |  awk '{print $4}')
echo $DEPLOYMENT_STATE
while [ $DEPLOYMENT_STATE != 1 ];
do DEPLOYMENT_STATE=$(kubectl get deployments | grep image-classifier-resnet50 |  awk '{print $4}') && echo $DEPLOYMENT_STATE;
done
kubectl apply -f tf-serving/service.yaml
echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"

kubectl apply -f tf-serving/gateway.yaml
kubectl apply -f tf-serving/virtualservice.yaml
echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo $GATEWAY_URL
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict
kubectl apply -f tf-serving/destinationrule.yaml
kubectl apply -f tf-serving/virtualservice-weight-100.yaml
sed -i "s/YOUR_BUCKET/$MODEL_BUCKET/g" tf-serving/configmap-resnet101.yaml
cat tf-serving/configmap-resnet101.yaml 
kubectl apply -f tf-serving/configmap-resnet101.yaml
cat tf-serving/deployment-resnet101.yaml
kubectl apply -f tf-serving/deployment-resnet101.yaml
DEPLOYMENT_STATE2=$(kubectl get deployments | grep image-classifier-resnet101 |  awk '{print $4}')
echo $DEPLOYMENT_STATE2
while [ $DEPLOYMENT_STATE2 != 1 ];
do DEPLOYMENT_STATE2=$(kubectl get deployments | grep image-classifier-resnet101 |  awk '{print $4}') && echo $DEPLOYMENT_STATE2 ;
done
echo "${GREEN}${BOLD}

Task 6 Completed

${RESET}"

curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict
kubectl apply -f tf-serving/virtualservice-weight-70.yaml
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict

echo "${GREEN}${BOLD}

Task 7 Completed

${RESET}"

curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict


kubectl apply -f tf-serving/virtualservice-focused-routing.yaml
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict
echo "${GREEN}${BOLD}

Task 8 Completed.

Game completed.

${RESET}"
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict
curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict

curl -d @payloads/request-body.json -H "user-group: canary" -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict



#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE
while [ $CONSENT_REMOVE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
logout
exit
