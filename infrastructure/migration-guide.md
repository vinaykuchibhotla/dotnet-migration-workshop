# Migration Guide: Legacy .NET to Modern AWS Services

This guide walks through migrating the legacy .NET Framework 4.8 application to modern AWS services.

## Migration Path Overview

### Phase 1: Database Migration (AWS DMS)
- **Source**: MySQL 8.0 on EC2
- **Target**: Amazon RDS for MySQL
- **Tool**: AWS Database Migration Service (DMS)

### Phase 2: Application Modernization
- **Option A**: AWS App2Container - Containerize existing application
- **Option B**: Replatform to .NET Core on AWS Lambda/ECS
- **Option C**: Refactor to serverless with API Gateway + Lambda

## Phase 1: Database Migration with AWS DMS

### 1. Create RDS MySQL Instance
```bash
aws rds create-db-instance \
    --db-instance-identifier workshop-mysql-rds \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0.35 \
    --master-username admin \
    --master-user-password RDSPassword123! \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-xxxxxxxxx \
    --db-subnet-group-name default-vpc-xxxxxxxx
```

### 2. Create DMS Replication Instance
```bash
aws dms create-replication-instance \
    --replication-instance-identifier workshop-dms-instance \
    --replication-instance-class dms.t3.micro \
    --vpc-security-group-ids sg-xxxxxxxxx \
    --replication-subnet-group-identifier default-vpc-xxxxxxxx
```

### 3. Create Source and Target Endpoints
```bash
# Source endpoint (EC2 MySQL)
aws dms create-endpoint \
    --endpoint-identifier workshop-source-mysql \
    --endpoint-type source \
    --engine-name mysql \
    --server-name 10.0.3.100 \
    --port 3306 \
    --username appuser \
    --password AppPassword123! \
    --database-name ProductCatalog

# Target endpoint (RDS MySQL)
aws dms create-endpoint \
    --endpoint-identifier workshop-target-rds \
    --endpoint-type target \
    --engine-name mysql \
    --server-name workshop-mysql-rds.xxxxxxxxx.region.rds.amazonaws.com \
    --port 3306 \
    --username admin \
    --password RDSPassword123! \
    --database-name ProductCatalog
```

### 4. Create and Start Migration Task
```bash
aws dms create-replication-task \
    --replication-task-identifier workshop-migration-task \
    --source-endpoint-arn arn:aws:dms:region:account:endpoint:workshop-source-mysql \
    --target-endpoint-arn arn:aws:dms:region:account:endpoint:workshop-target-rds \
    --replication-instance-arn arn:aws:dms:region:account:rep:workshop-dms-instance \
    --migration-type full-load-and-cdc \
    --table-mappings file://table-mappings.json
```

## Phase 2A: Application Containerization with App2Container

### 1. Install App2Container on Windows Server
```powershell
# Download and install App2Container
Invoke-WebRequest -Uri "https://app2container-release-us-east-1.s3.us-east-1.amazonaws.com/latest/windows/AWSApp2Container-installer-windows.zip" -OutFile "app2container.zip"
Expand-Archive -Path "app2container.zip" -DestinationPath "C:\app2container"
C:\app2container\install.ps1
```

### 2. Initialize App2Container
```powershell
app2container init
```

### 3. Analyze Application
```powershell
# Discover IIS applications
app2container inventory

# Analyze the ProductCatalog application
app2container analyze --application-id iis-productcatalog-80
```

### 4. Extract and Containerize
```powershell
# Extract application
app2container extract --application-id iis-productcatalog-80

# Containerize application
app2container containerize --application-id iis-productcatalog-80
```

### 5. Generate Deployment Artifacts
```powershell
# Generate CloudFormation templates for ECS deployment
app2container generate app-deployment --application-id iis-productcatalog-80
```

## Phase 2B: Modernization to .NET Core

### 1. Assessment with Porting Assistant
- Install .NET Portability Analyzer
- Analyze compatibility with .NET Core/.NET 5+
- Identify incompatible APIs and dependencies

### 2. Code Migration Steps
1. Create new .NET Core Web API project
2. Migrate data access layer to Entity Framework Core
3. Convert WebForms to MVC/Razor Pages or React SPA
4. Update dependency injection and configuration
5. Implement health checks and logging

### 3. Deploy to AWS App Runner
```bash
# Build and push container
docker build -t productcatalog-core .
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin account.dkr.ecr.us-east-1.amazonaws.com
docker tag productcatalog-core:latest account.dkr.ecr.us-east-1.amazonaws.com/productcatalog-core:latest
docker push account.dkr.ecr.us-east-1.amazonaws.com/productcatalog-core:latest

# Create App Runner service
aws apprunner create-service --cli-input-json file://apprunner-config.json
```

## Phase 2C: Serverless Refactoring

### 1. API Design
- Break monolith into microservices
- Design RESTful APIs for product operations
- Implement authentication with Amazon Cognito

### 2. Lambda Functions
```csharp
// Example Lambda function for GetProducts
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

public class ProductFunction
{
    public async Task<APIGatewayProxyResponse> GetProducts(APIGatewayProxyRequest request, ILambdaContext context)
    {
        // Implementation
    }
}
```

### 3. Infrastructure as Code
```yaml
# SAM template for serverless deployment
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  ProductApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: prod
      
  GetProductsFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/
      Handler: ProductCatalog::ProductCatalog.ProductFunction::GetProducts
      Runtime: dotnet6
      Events:
        GetProducts:
          Type: Api
          Properties:
            RestApiId: !Ref ProductApi
            Path: /products
            Method: get
```

## Migration Checklist

### Pre-Migration
- [ ] Backup source database
- [ ] Document current application architecture
- [ ] Identify dependencies and integrations
- [ ] Plan downtime window

### Database Migration
- [ ] Create RDS instance
- [ ] Set up DMS replication instance
- [ ] Configure source and target endpoints
- [ ] Test connectivity
- [ ] Run full load migration
- [ ] Validate data integrity
- [ ] Set up CDC for ongoing replication

### Application Migration
- [ ] Choose migration strategy (rehost/replatform/refactor)
- [ ] Update database connection strings
- [ ] Test application with new database
- [ ] Implement monitoring and logging
- [ ] Configure auto-scaling
- [ ] Set up CI/CD pipeline

### Post-Migration
- [ ] Performance testing
- [ ] Security review
- [ ] Cost optimization
- [ ] Documentation update
- [ ] Team training
- [ ] Decommission legacy infrastructure

## Troubleshooting Common Issues

### DMS Migration Issues
- **Connection failures**: Check security groups and network ACLs
- **Slow performance**: Increase replication instance size
- **Data validation errors**: Review character sets and collations

### App2Container Issues
- **Discovery failures**: Ensure IIS applications are running
- **Containerization errors**: Check Windows container compatibility
- **Deployment issues**: Verify ECS cluster configuration

### Performance Optimization
- **Database**: Implement connection pooling, query optimization
- **Application**: Enable output caching, compress responses
- **Infrastructure**: Use CloudFront CDN, implement auto-scaling
