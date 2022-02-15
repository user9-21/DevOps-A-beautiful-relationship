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

#git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
#cd python-docs-samples/codelabs/flex_and_vision

mkdir python-docs-samples
mkdir python-docs-samples/codelabs
mkdir python-docs-samples/codelabs/flex_and_vision
mkdir python-docs-samples/codelabs/flex_and_vision/templates
cd python-docs-samples/codelabs/flex_and_vision/templates
curl -o homepage.html https://raw.githubusercontent.com/GoogleCloudPlatform/python-docs-samples/main/codelabs/flex_and_vision/templates/homepage.html
ls
cd python-docs-samples/codelabs/flex_and_vision
curl -o main_test.py https://raw.githubusercontent.com/GoogleCloudPlatform/python-docs-samples/main/codelabs/flex_and_vision/main_test.py
curl -o main.py https://raw.githubusercontent.com/GoogleCloudPlatform/python-docs-samples/main/codelabs/flex_and_vision/main.py
curl -o requirements.txt https://raw.githubusercontent.com/GoogleCloudPlatform/python-docs-samples/main/codelabs/flex_and_vision/requirements.txt
cat > app.yaml << EOF
runtime: python
env: flex
entrypoint: gunicorn -b :$PORT main:app

runtime_config:
  python_version: 3

env_variables:
  CLOUD_STORAGE_BUCKET: $PROJECT_ID
manual_scaling:
  instances: 1
EOF

ls

gcloud iam service-accounts create qwiklab \
  --display-name "My Qwiklab Service Account"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member serviceAccount:qwiklab@${PROJECT_ID}.iam.gserviceaccount.com \
--role roles/owner
gcloud iam service-accounts keys create ~/key.json \
--iam-account qwiklab@${PROJECT_ID}.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS="/home/${USER}/key.json"
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"


virtualenv -p python3 env
source env/bin/activate
pip install -r requirements.txt
gcloud config set compute/zone us-central1-a
gcloud app create --region "us-central"
export CLOUD_STORAGE_BUCKET=${PROJECT_ID}
gsutil mb gs://${PROJECT_ID}


echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"
python main.py
gcloud config set app/cloud_build_timeout 1000
gcloud app deploy --quiet

echo "${GREEN}${BOLD}

Task 3 Completed.

Game Completed

${RESET}"
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
