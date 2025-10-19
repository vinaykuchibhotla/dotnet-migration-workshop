#!/bin/bash
# Deployment script for Legacy .NET Application Migration Workshop

set -e

# Configuration
STACK_NAME="dotnet-migration-workshop"
REGION="us-east-1"
KEY_PAIR_NAME=""
GITHUB_REPO_URL=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Check if CloudFormation template exists
    if [ ! -f "infrastructure/cloudformation-template.yaml" ]; then
        print_error "CloudFormation template not found. Please run this script from the workshop root directory."
        exit 1
    fi
    
    print_status "Prerequisites check passed."
}

# Function to get user input
get_user_input() {
    if [ -z "$KEY_PAIR_NAME" ]; then
        echo -n "Enter your EC2 Key Pair name: "
        read KEY_PAIR_NAME
    fi
    
    if [ -z "$GITHUB_REPO_URL" ]; then
        echo -n "Enter your GitHub repository URL (optional, press Enter to skip): "
        read GITHUB_REPO_URL
    fi
    
    echo -n "Enter AWS region (default: us-east-1): "
    read input_region
    if [ ! -z "$input_region" ]; then
        REGION=$input_region
    fi
}

# Function to validate key pair
validate_key_pair() {
    print_status "Validating EC2 Key Pair..."
    if ! aws ec2 describe-key-pairs --key-names "$KEY_PAIR_NAME" --region "$REGION" &> /dev/null; then
        print_error "Key pair '$KEY_PAIR_NAME' not found in region '$REGION'."
        print_warning "Please create the key pair first or use an existing one."
        exit 1
    fi
    print_status "Key pair validation passed."
}

# Function to deploy CloudFormation stack
deploy_stack() {
    print_status "Deploying CloudFormation stack..."
    
    aws cloudformation create-stack \
        --stack-name "$STACK_NAME" \
        --template-body file://infrastructure/cloudformation-template.yaml \
        --parameters ParameterKey=KeyPairName,ParameterValue="$KEY_PAIR_NAME" \
                    ParameterKey=Region,ParameterValue="$REGION" \
        --capabilities CAPABILITY_IAM \
        --region "$REGION"
    
    print_status "Stack creation initiated. Waiting for completion..."
    
    aws cloudformation wait stack-create-complete \
        --stack-name "$STACK_NAME" \
        --region "$REGION"
    
    if [ $? -eq 0 ]; then
        print_status "Stack deployed successfully!"
    else
        print_error "Stack deployment failed. Check AWS CloudFormation console for details."
        exit 1
    fi
}

# Function to get stack outputs
get_stack_outputs() {
    print_status "Retrieving stack outputs..."
    
    WINDOWS_IP=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`WindowsServerPrivateIP`].OutputValue' \
        --output text)
    
    MYSQL_IP=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`MySQLServerPrivateIP`].OutputValue' \
        --output text)
    
    VPC_ID=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`VPCId`].OutputValue' \
        --output text)
}

# Function to display deployment information
display_info() {
    echo ""
    echo "============================================"
    echo "   DEPLOYMENT COMPLETED SUCCESSFULLY!"
    echo "============================================"
    echo "Stack Name: $STACK_NAME"
    echo "Region: $REGION"
    echo "VPC ID: $VPC_ID"
    echo "Windows Server IP: $WINDOWS_IP"
    echo "MySQL Server IP: $MYSQL_IP"
    echo ""
    echo "Next Steps:"
    echo "1. Wait 10-15 minutes for instances to complete setup"
    echo "2. Connect to Windows server via RDP using your key pair"
    echo "3. Access application at http://$WINDOWS_IP/ProductCatalog/"
    echo "4. Begin migration workshop exercises"
    echo ""
    echo "Troubleshooting:"
    echo "- Check EC2 instance logs in AWS Console"
    echo "- Verify security groups allow required ports"
    echo "- Ensure instances have internet connectivity via NAT Gateway"
    echo "============================================"
}

# Function to cleanup on failure
cleanup_on_failure() {
    print_warning "Cleaning up failed deployment..."
    aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION" 2>/dev/null || true
}

# Main execution
main() {
    echo "============================================"
    echo "  Legacy .NET Migration Workshop Deployer"
    echo "============================================"
    echo ""
    
    check_prerequisites
    get_user_input
    validate_key_pair
    
    # Set trap for cleanup on failure
    trap cleanup_on_failure ERR
    
    deploy_stack
    get_stack_outputs
    display_info
    
    print_status "Workshop environment is ready!"
}

# Run main function
main "$@"
