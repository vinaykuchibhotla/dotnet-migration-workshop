# Legacy .NET Application Migration Workshop Instructions

## Workshop Overview
This hands-on workshop demonstrates migrating a legacy .NET Framework 4.8 WebForms application from EC2 to modern AWS services. Participants will experience the complete migration journey from assessment to modernization.

## Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured
- EC2 Key Pair in target region
- Basic knowledge of .NET and AWS services

## Workshop Architecture

### Legacy Environment
- **Application**: .NET Framework 4.8 WebForms on Windows Server 2019
- **Database**: MySQL 8.0 on Amazon Linux 2
- **Infrastructure**: VPC with public/private subnets, NAT Gateway
- **Data**: 10,000+ product records for realistic testing

### Target Architecture Options
1. **Rehost**: App2Container → Amazon ECS
2. **Replatform**: .NET Core → AWS App Runner
3. **Refactor**: Serverless → API Gateway + Lambda

## Lab Exercises

### Lab 1: Deploy Legacy Environment (30 minutes)

#### Step 1: Clone Workshop Repository
```bash
git clone https://github.com/vinaykuchibhotla/dotnet-migration-workshop.git
cd dotnet-migration-workshop
```

#### Step 2: Deploy Infrastructure
```bash
# Make script executable
chmod +x scripts/deploy-workshop.sh

# Run deployment
./scripts/deploy-workshop.sh
```

#### Step 3: Verify Deployment
1. Wait 10-15 minutes for EC2 instances to complete setup
2. Check CloudFormation stack status in AWS Console
3. Note the Windows and MySQL server IP addresses
4. Verify application accessibility

#### Expected Outcome
- Functional .NET WebForms application
- MySQL database with 10,000+ products
- Application accessible via browser

### Lab 2: Explore Legacy Application (20 minutes)

#### Step 1: Connect to Windows Server
```bash
# Get Windows server public IP from CloudFormation outputs
aws cloudformation describe-stacks --stack-name dotnet-migration-workshop \
  --query 'Stacks[0].Outputs[?OutputKey==`WindowsServerPrivateIP`].OutputValue' --output text
```

#### Step 2: Access Application
1. Open browser to `http://WINDOWS_SERVER_IP/ProductCatalog/`
2. Test search functionality
3. Navigate through product pages
4. Observe application performance

#### Step 3: Examine Architecture
1. Review IIS configuration
2. Check database connection in Web.config
3. Analyze application structure
4. Document current state

#### Expected Outcome
- Understanding of legacy application structure
- Baseline performance metrics
- Identified modernization opportunities

### Lab 3: Database Migration with AWS DMS (45 minutes)

#### Step 1: Create Target RDS Instance
```bash
# Create RDS MySQL instance
aws rds create-db-instance \
    --db-instance-identifier workshop-mysql-rds \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0.35 \
    --master-username admin \
    --master-user-password RDSPassword123! \
    --allocated-storage 20 \
    --storage-type gp2 \
    --vpc-security-group-ids $(aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=*MySQL*" \
        --query 'SecurityGroups[0].GroupId' --output text) \
    --no-publicly-accessible
```

#### Step 2: Set Up DMS Replication
1. Create DMS replication instance
2. Configure source endpoint (EC2 MySQL)
3. Configure target endpoint (RDS MySQL)
4. Test endpoint connections

#### Step 3: Create Migration Task
1. Use provided table mappings configuration
2. Configure full-load and CDC
3. Start migration task
4. Monitor migration progress

#### Step 4: Validate Migration
1. Compare record counts
2. Verify data integrity
3. Test application with RDS connection
4. Monitor CDC for ongoing changes

#### Expected Outcome
- Successful database migration to RDS
- Application working with new database
- Understanding of DMS capabilities

### Lab 4: Application Containerization (60 minutes)

#### Step 1: Install App2Container
```powershell
# On Windows Server, download and install App2Container
Invoke-WebRequest -Uri "https://app2container-release-us-east-1.s3.us-east-1.amazonaws.com/latest/windows/AWSApp2Container-installer-windows.zip" -OutFile "app2container.zip"
Expand-Archive -Path "app2container.zip" -DestinationPath "C:\app2container"
C:\app2container\install.ps1
```

#### Step 2: Application Discovery
```powershell
# Initialize App2Container
app2container init

# Discover IIS applications
app2container inventory
```

#### Step 3: Analysis and Extraction
```powershell
# Analyze the ProductCatalog application
app2container analyze --application-id iis-productcatalog-80

# Review analysis report
# Extract application artifacts
app2container extract --application-id iis-productcatalog-80
```

#### Step 4: Containerization
```powershell
# Create container image
app2container containerize --application-id iis-productcatalog-80

# Test container locally
docker run -p 8080:80 app2container/iis-productcatalog-80
```

#### Step 5: Generate Deployment Artifacts
```powershell
# Generate CloudFormation templates for ECS
app2container generate app-deployment --application-id iis-productcatalog-80
```

#### Expected Outcome
- Containerized .NET application
- ECS deployment templates
- Understanding of App2Container workflow

### Lab 5: Modern Deployment Options (45 minutes)

#### Option A: Deploy to Amazon ECS
1. Create ECS cluster
2. Deploy using generated CloudFormation
3. Configure load balancer
4. Test containerized application

#### Option B: Modernize to .NET Core
1. Assess .NET Core compatibility
2. Create new .NET Core project
3. Migrate data access layer
4. Deploy to AWS App Runner

#### Option C: Serverless Refactoring
1. Design API structure
2. Create Lambda functions
3. Set up API Gateway
4. Deploy serverless application

#### Expected Outcome
- Experience with multiple modernization paths
- Understanding of trade-offs
- Functional modern application

### Lab 6: Monitoring and Optimization (30 minutes)

#### Step 1: Implement Monitoring
1. Set up CloudWatch metrics
2. Configure application insights
3. Create custom dashboards
4. Set up alerts

#### Step 2: Performance Testing
1. Use load testing tools
2. Compare legacy vs modern performance
3. Identify bottlenecks
4. Optimize configurations

#### Step 3: Cost Analysis
1. Review AWS Cost Explorer
2. Compare legacy vs modern costs
3. Identify optimization opportunities
4. Set up cost alerts

#### Expected Outcome
- Comprehensive monitoring setup
- Performance comparison data
- Cost optimization insights

## Workshop Deliverables

### Individual Deliverables
- [ ] Deployed legacy environment
- [ ] Completed database migration
- [ ] Containerized application
- [ ] Modern deployment (choose one path)
- [ ] Monitoring dashboard
- [ ] Migration assessment report

### Team Discussion Points
1. **Migration Strategy Selection**
   - When to rehost vs replatform vs refactor?
   - Cost-benefit analysis of each approach
   - Risk assessment and mitigation

2. **Technical Challenges**
   - Database compatibility issues
   - Application dependencies
   - Performance considerations

3. **Operational Improvements**
   - Monitoring and alerting
   - Backup and disaster recovery
   - Security enhancements

## Troubleshooting Guide

### Common Issues and Solutions

#### CloudFormation Deployment Fails
- **Issue**: Stack creation fails
- **Solution**: Check IAM permissions, verify key pair exists, ensure region availability

#### Application Not Accessible
- **Issue**: Cannot reach application URL
- **Solution**: Check security groups, verify NAT Gateway, confirm IIS is running

#### Database Connection Errors
- **Issue**: Application cannot connect to MySQL
- **Solution**: Verify security groups, check MySQL service status, validate credentials

#### DMS Migration Fails
- **Issue**: Migration task fails or stalls
- **Solution**: Check endpoint connectivity, verify permissions, review CloudWatch logs

#### App2Container Issues
- **Issue**: Discovery or containerization fails
- **Solution**: Ensure IIS application is running, check Windows container support, verify permissions

### Getting Help
- Review CloudWatch logs for detailed error messages
- Check AWS service health dashboard
- Consult workshop facilitators
- Use AWS documentation and forums

## Next Steps After Workshop

### Immediate Actions
1. Clean up workshop resources to avoid charges
2. Document lessons learned
3. Plan actual migration timeline
4. Identify team training needs

### Long-term Planning
1. Conduct thorough application assessment
2. Develop comprehensive migration strategy
3. Set up CI/CD pipelines
4. Implement security best practices
5. Plan ongoing optimization

### Additional Resources
- [AWS Application Migration Service](https://aws.amazon.com/application-migration-service/)
- [AWS App2Container Documentation](https://docs.aws.amazon.com/app2container/)
- [AWS Database Migration Service](https://aws.amazon.com/dms/)
- [.NET on AWS](https://aws.amazon.com/developer/language/net/)

## Cleanup Instructions

### Delete Workshop Resources
```bash
# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name dotnet-migration-workshop

# Delete RDS instance (if created)
aws rds delete-db-instance --db-instance-identifier workshop-mysql-rds --skip-final-snapshot

# Delete DMS resources (if created)
aws dms delete-replication-task --replication-task-arn <task-arn>
aws dms delete-replication-instance --replication-instance-arn <instance-arn>
```

### Verify Cleanup
- Check CloudFormation console for stack deletion
- Verify no running EC2 instances
- Confirm RDS instances are terminated
- Review billing dashboard for any remaining charges