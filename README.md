# Legacy .NET Application Migration Workshop

This workshop demonstrates migrating a legacy .NET Framework 4.8 WebForms application from EC2 to modern AWS services.

## Architecture

- **Legacy Application**: .NET Framework 4.8 WebForms on Windows Server 2019
- **Database**: MySQL 8.0 on Linux EC2
- **Infrastructure**: VPC with public/private subnets, NAT Gateway
- **Migration Path**: AWS DMS for database, App2Container for application

## Quick Start

1. Deploy infrastructure:
```bash
aws cloudformation create-stack \
  --stack-name dotnet-migration-workshop \
  --template-body file://infrastructure/cloudformation-template.yaml \
  --parameters ParameterKey=KeyPairName,ParameterValue=your-key-pair \
  --capabilities CAPABILITY_IAM
```

2. Access application via Windows server public IP on port 80

## Workshop Flow

1. **Deploy Legacy Environment** - Use CloudFormation to create EC2-based infrastructure
2. **Explore Application** - Access WebForms application showing product catalog
3. **Database Migration** - Use AWS DMS to migrate MySQL to RDS
4. **Application Modernization** - Use App2Container to containerize application

## Components

- `/src/` - .NET WebForms application source code
- `/infrastructure/` - CloudFormation templates and scripts
- `/database/` - MySQL schema and sample data
- `/scripts/` - Deployment and setup scripts

## Prerequisites

- AWS CLI configured
- EC2 Key Pair in target region
- GitHub repository for source code hosting