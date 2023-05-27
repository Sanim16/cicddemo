# A Complete CI/CD with Terraform and AWS

>This is a CICD project that dockerises a nodejs website created with "npx create-react-app"

>It also uses a terraform file to provision infrastructure on AWS for deployment of the app.

## Technologies:
- Terraform
- GitHub Actions
- Docker
- Node.js
- AWS EC2
- AWS S3
- AWS ECR


## Tasks:

- Get access ID, secret ID from AWS and ensure user has enough permissions to create infrastructure
- Develop a simple nodejs app
```js
npx create-react-app nodeapp
```

- Write a Dockerfile for the nodejs app, it should be in the nodeapp folder
```Dockerfile
FROM node:lts-alpine
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --production --silent && mv node_modules ../
COPY . .
EXPOSE 3000
RUN chown -R node /usr/src/app
USER node
CMD ["npm", "start"]
```

- Generate SSH keys for connecting to EC2 instance
- Create an S3 bucket, that will be the remote backend used for storing Terraform State file

- Write Terraform Scripts for provisioning the Infrastructure on AWS

## Write CI/CD pipeline

- Write GitHub Actions workflow: Set environment variables

```yml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  PRIVATE_SSH_KEY: ${{ secrets.AWS_SSH_KEY_PRIVATE }}
  PUBLIC_SSH_KEY: ${{ secrets.AWS_SSH_KEY_PUBLIC }}
  TF_STATE_BUCKET_NAME: ${{ secrets.TF_STATE_BUCKET_NAME }}
```
- Setup backend for S3 bucket with terraform init

```yml
    - name: Checkout
        uses: actions/checkout@v3
    - name: setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_wrapper: false
    - name: Terraform init
        id: init
        run: terraform init -backend-config="bucket=$TF_STATE_BUCKET_NAME" -backend-config="region=us-east-1"
        working-directory: ./terraform
```

- Pass tf variables with Terraform plan

```yml
- name: Terraform Plan
  id: plan
  run: |-
    terraform plan \
    -var="public_key=$PUBLIC_SSH_KEY" \
    -var="private_key=$PRIVATE_SSH_KEY" \
    -var="key_name=terraformawskey" \
    -out=PLAN
  working-directory: ./terraform
```
>Amend the terraform plan command to terraform plan -destroy \ when taking down the infrastructure

- Run terraform apply

```yml
- name: Terraform Apply
  id: apply
  run: terraform apply PLAN
  working-directory: ./terraform
```

- Set EC2 instance public ip as job output

```yml
- name: Set IP for EC2 instance
  id: set-ip
  run: echo "web_server_public_ip=$(terraform output web_server_public_ip)" >> $GITHUB_OUTPUT
  working-directory: ./terraform
```

- Authenticate ECR
```yml
- name: Login to AWS ECR
  id: login-ecr
  uses: aws-actions/amazon-ecr-login@v1
```

- Set EC2 public ip as environment variable for later use

```yml
- name: Get the EC2 IP from job deploy-infra
  run: |-
    echo ${{needs.deploy-infra.outputs.EC2_PUBLIC_IP}}
    echo "EC2_PUBLIC_IP=${{needs.deploy-infra.outputs.EC2_PUBLIC_IP}}" >> $GITHUB_ENV
```

- Build, tag and push docker image to Amazon ECR
>The repository should exist already or can be provisioned in Terraform

```yml
- name: Build and Push docker image
  env:
    REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    REPOSITORY: example-node-app
    IMAGE_TAG: ${{ github.sha }}
  run: |-
    docker build -t $REGISTRY/$REPOSITORY:$IMAGE_TAG .
    docker push $REGISTRY/$REPOSITORY:$IMAGE_TAG
  working-directory: ./nodeapp
```

- Connect to EC2 using ssh and deploy docker container

```yml
- name: Deploy Docker Image to EC2
  env:
    REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    REPOSITORY: example-node-app
    IMAGE_TAG: ${{ github.sha }}
    AWS_DEFAULT_REGION: us-east-1
  uses: appleboy/ssh-action@master
  with:
    host: ${{ env.EC2_PUBLIC_IP }}
    username: ubuntu
    key: ${{ env.PRIVATE_SSH_KEY }}
    envs: PRIVATE_SSH_KEY,REGISTRY,REPOSITORY,IMAGE_TAG,AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_DEFAULT_REGION,AWS_REGION
    script: |-
        sudo apt update
        sudo apt install docker.io -y
        sudo apt install awscli -y
        sudo $(aws ecr get-login --no-include-email --region us-east-1);
        sudo docker stop myappcontainer || true
        sudo docker rm myappcontainer || true
        sudo docker pull $REGISTRY/$REPOSITORY:$IMAGE_TAG
        sudo docker run -d --name myappcontainer -p 80:3000 $REGISTRY/$REPOSITORY:$IMAGE_TAG
```
