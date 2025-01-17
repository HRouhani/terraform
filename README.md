# Terraform Repository for Cloud Testing Environments

This repository contains Terraform configurations for deploying a variety of cloud resources and infrastructure components. The setup is tailored for creating testing environments, particularly for cybersecurity tool assessments. The deployed environment includes clusters on Azure, AKS (Azure Kubernetes Service), EKS (Amazon Elastic Kubernetes Service), and a Windows domain with a domain controller and joined domain servers.

## **Features**

1. **Azure Resources**:
   - Configurations to deploy various Azure resources, including virtual machines, networking, and storage.

2. **AKS (Azure Kubernetes Service)**:
   - Automates the deployment of Kubernetes clusters on Azure.

3. **EKS (Amazon Elastic Kubernetes Service)**:
   - Automates the deployment of Kubernetes clusters on AWS.

4. **Windows Domain**:
   - A complete Windows domain setup with a domain controller.
   - Additional Windows servers joined to the domain.

5. **Cybersecurity Testing**:
   - This environment is designed for testing cybersecurity tools, specifically their ability to scan and detect misconfigurations across hybrid and multi-cloud setups.

## **Use Cases**

- Testing and validating cybersecurity tools.
- Simulating real-world misconfigurations for security testing.
- Learning and experimenting with cloud infrastructure and Kubernetes deployments.

## **Pre-requisites**

- **Terraform**: Ensure you have the latest version of Terraform installed. You can download it from [Terraform's official site](https://www.terraform.io/downloads.html).
- **Cloud Credentials**: Access credentials for Azure and AWS to provision resources.
- **Windows License**: Ensure you have appropriate licensing for Windows servers if deploying in production.
- **Azure Authentication**:
  - To deploy to Azure, ensure you are authenticated to your Azure cloud via terminal using the following command:
    ```bash
    az login
    ```
  - If `az` CLI is not installed, you can install it on Ubuntu using:
    ```bash
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    ```
- **AWS Authentication**:
  - To authenticate to AWS from the Linux terminal, follow these steps:
    1. Install the AWS CLI:
       ```bash
       sudo apt update
       sudo apt install awscli -y
       ```
    2. Configure AWS CLI with your credentials:
       ```bash
       aws configure
       ```
       You will be prompted to enter:
       - AWS Access Key ID
       - AWS Secret Access Key
       - Default region (e.g., `us-east-1`)
       - Output format (e.g., `json` or `text`)
    3. Verify your configuration:
       ```bash
       aws s3 ls
       ```
       This should list your S3 buckets if the configuration is correct.

## **Setup Instructions**

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/terraform-cloud-testing.git
   cd terraform-cloud-testing
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Deploy the infrastructure:
   ```bash
   terraform apply
   ```
   - Review the planned changes and confirm by typing `yes`.

4. Wait for the deployment to complete. Terraform will output the necessary details such as IP addresses, login credentials, etc.

## **Folder Structure**

- `azure/`: Contains Terraform configurations for Azure resources.
- `aks/`: Configurations for AKS (Azure Kubernetes Service).
- `eks/`: Configurations for EKS (Amazon Elastic Kubernetes Service).
- `windows-domain/`: Configurations for deploying a Windows domain, domain controller, and joined servers.

## **Testing Cybersecurity Tools**

This setup is ideal for testing the following scenarios:

1. **Misconfigurations**:
   - Validate if the tools can identify common cloud and domain misconfigurations.

2. **Kubernetes Security**:
   - Test the ability of tools to scan AKS and EKS clusters for security gaps.

3. **Windows Domain Security**:
   - Assess how tools handle scanning a Windows domain setup, including policies, access control, and configurations.

## **Clean-Up**

To remove all resources:
```bash
terraform destroy
```
- Confirm by typing `yes`.

## **Contributing**

Contributions are welcome! Please submit a pull request or open an issue for any suggestions or improvements.

## **License**

This project is licensed under the [MIT License](LICENSE).

---

Happy testing and securing your infrastructure!