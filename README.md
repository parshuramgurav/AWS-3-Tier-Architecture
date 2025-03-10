# Introduction to 3-Tier Architecture

3-Tier Architecture is a software design pattern that divides an application into three distinct layers or tiers, each handling specific tasks to improve scalability, maintainability, and modularity. By clearly separating these layers, developers can manage each aspect independently, simplifying development, testing, and deployment processes.

## The Three Layers

### 1. Presentation Tier (User Interface Layer)
- This is the topmost layer of the application, interacting directly with the end-users.
- It gathers user input, displays output, and provides an interface such as webpages, desktop applications, or mobile apps.

### 2. Application Tier (Business Logic Layer)
- This intermediate layer handles the application’s logic, processes user requests, and applies business rules.
- It communicates between the presentation layer and the data layer, ensuring correct data handling and efficient application workflow.

### 3. Data Tier (Database Layer)
- This bottom layer stores and retrieves data, managing interactions with databases or data storage systems.
- It ensures data integrity, security, and efficient data transactions.

## Benefits of 3-Tier Architecture
- **Scalability**: Each tier can be scaled individually based on demand.
- **Maintainability**: Easier to maintain, test, and debug as each layer operates independently.
- **Flexibility**: Allows different technologies to be integrated into each layer without affecting others.
- **Security**: Clear separation helps in enforcing stronger security measures at each level.

---

# Project Overview

The purpose of this project is to design and implement a scalable, highly available, and fault-tolerant three-tier architecture on AWS. The proposed architecture includes a Web Tier and Application Tier, each configured with its own Auto Scaling Groups (ASG), and a Database Tier set up across multiple Availability Zones (Multi-AZ). External and Internal Load Balancers will be deployed to efficiently accept and distribute incoming requests.

To streamline the deployment and focus on application-specific tasks, essential infrastructure components have already been provisioned. Specifically, the Virtual Private Cloud (VPC), including all associated networking elements such as subnets, route tables, security groups, and Internet gateways, is fully configured and ready for immediate use. Additionally, the Database Tier has been preconfigured as a highly available Multi-AZ setup, ensuring reliability and fault tolerance. Your task is primarily to deploy and configure the Web and Application tiers, leveraging these existing resources.

---

# User Part

## Creating Web Server in Public Subnet

### Step 1: Launch EC2 Instance
- From the AWS console, select EC2.
- From the left sidebar, select Instances.
- Click Launch instances.

### Step 2: Add Tags (Important step at the beginning)
- Under Name and tags, click Add tag:
  - Key: Name
  - Value: web server instance (or any desired name)
- Click Add additional tags and enter:
  - Key: Environment
  - Value: cloudlearn
- **Note**: Ensure you add the Environment tag.

### Step 3: Choose Amazon Machine Image (AMI)
- Select Amazon Linux 2.

### Step 4: Configure Instance Type
- Choose instance type (t2.micro for Free Tier or as per your requirements).
- Click Next to proceed.

### Step 5: Key Pair Selection
- Under Key pair, select Proceed without a key pair (as you are using AWS SSM).

### Step 6: Network Settings
- Select your existing VPC.
- For Subnet, choose your Public Subnet.
- Auto-assign Public IP: Choose Disable.

### Step 7: Security Group
- Select existing security group.
- Choose your previously created web-server security group.

### Step 8: Storage Settings
- Keep the default storage settings (no changes required).

### Step 9: IAM Role
- Under IAM instance profile, select WebServerIAMRole (this enables login via AWS SSM).

### Step 10: Launch Instance
- Review your configuration carefully.
- Click Launch instances.

---
## Install Nginx Server And Deploy Code In Web Server

Before Installing The Nginx Server We Need To Have The Internal Laod Balancer Ready
- [Please Use this Link For Creating Internal ALB](#Chapter2)

### Step 1: Save The Script
- Save the file as, for example, web-setup.sh.

### Step 2: Make It Executable
   ```bash
  chmod +x web-setup.sh
  ```
### Step 3: Run the Script While Providing The Internal Load Balancer DNS As The First Argument
  ```bash
    ./web-setup.sh <Your-Internal-LoadBalancer-DNS>
   ``` 
---
## Creating Application Server in Private Subnet

### Step 1: Launch EC2 Instance
- Navigate to EC2 in AWS Management Console.
- From the left sidebar, click on Instances.
- Click the Launch instances button.

### Step 2: Add Tags (Important step at the beginning)
- Under Name and tags:
  - Click Add tag and enter:
    - Key: Name
    - Value: app server instance (or your preferred name)
  - Click Add additional tags and enter:
    - Key: Environment
    - Value: cloudlearn
- **Note**: Ensure you include the Environment tag.

### Step 3: Select AMI
- Select Amazon Linux 2 or your desired Linux AMI.

### Step 4: Configure Instance Type
- Select instance type (t2.micro or your desired instance type).
- Click Next.

### Step 5: Key Pair Selection
- Under Key pair, select Proceed without a key pair (you’ll use AWS SSM for access).

### Step 6: Network Settings
- Select your existing VPC.
- For Subnet, select your Private Subnet.
- Auto-assign Public IP: Choose Disable.

### Step 7: Security Group
- Select existing security group.
- Choose the pre-configured app-server security group.

### Step 8: Storage Configuration
- Keep the default storage settings unchanged.

### Step 9: Advanced Details (IAM Role)
- Under IAM instance profile, select AppServerIAMRole (allows SSM access to your instance).

### Step 10: Launch the Instance
- Review all settings carefully.
- Click Launch instances.

---

## Install MySql and NodeJS And Deploy Code In APPServer

 Before Installing The NodeJS Server We Need To Create Port Opening From Application Servers to DB Instance
- [Please Use this Link For Port Opening Guide](#Chapter1)

### Step 1: Download "setup.sh" File From GitHub Repo into your Application Server 

### Step 2: Save The Script
- Save the file as, for example, app-setup.sh.

### Step 3: Make It Executable
   ```bash
  chmod +x app-setup.sh
  ```
### Step 4: Run the Script
  ```bash
    ./app-setup.sh
  ```
### Step 5: Start Application with PM2, PM2 is process manager for NodeJS
   ```bash
  pm2 start index.js
  ```

### To See Logs
  ```bash
  pm2 logs
  ```

  -  Note: run Ctrl+C to exit

### Set PM2 to Start on Boot
  ```bash
    pm2 startup 
    sudo env PATH=$PATH:/home/ec2-user/.nvm/versions/node/v16.20.2/bin /home/ec2-user/.nvm/versions/node/v16.20.2/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user
  ```
### Save The Current Configuration
  ```bash  
    pm2 save
  ```
### To Do The Health Check
  ```bash
    curl http://localhost:4000/health
  ```

---

## Creating Launch Template for Web Server

### Step 1: Navigate to Launch Templates
- Go to the AWS Console, select EC2.
- In the left sidebar, click on Launch Templates.
- Click on Create launch template.

### Step 2: Enter Template Name and Description
- Launch template name: Provide a meaningful name (e.g., WebServerTemplate).
- Template version description: Add a brief description (e.g., “Launch template for Web Server instances”).

### Step 3: Add Template Tags (Important step)
- Under Template tags, click Add new tag:
  - Key: Name
  - Value: web server instance (or the same name used earlier)
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn
- **Note**: Ensure the above tags exactly match those added previously when creating your Web and App servers.

### Step 4: Select AMI (Application and OS Images)
- Under Application and OS Images:
  - Select My AMIs → Owned by me.
  - From the dropdown, select the previously created AMI you want to use.

### Step 5: Select Instance Type
- Choose t2.micro from the dropdown menu.

### Step 6: Key Pair (login)
- Under Key pair name, select Don’t include in launch template.

### Step 7: Network Settings
- Leave settings unchanged:
  - Subnet: Keep as Don’t include in launch template.
  - Security groups: Do not select any security group (leave blank).

### Step 8: Storage (Volumes)
- Leave the default settings unchanged (no changes needed).

### Step 9: Resource Tags (Important)
- Under Resource tags, click Add new tag:
  - Key: Name
  - Value: web server
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn

### Step 10: Advanced Details
- Under Advanced details, select WebServerIAMRole from the dropdown for IAM instance profile.
- Leave all other advanced details at their default values (do not modify anything else).

### Step 11: Create Launch Template
- Carefully review the provided details.
- Click Create launch template.

---

## Creating Launch Template for App Server (deselect the ASG option)

### Step 1: Navigate to Launch Templates
- Log in to AWS Management Console and open EC2.
- On the left sidebar, click on Launch Templates.
- Click on Create launch template.

### Step 2: Enter Template Name and Description
- Launch template name: Enter a suitable name (e.g., AppServerTemplate).
- Template version description: Add a description (e.g., “Launch template for App Server instances”).

### Step 3: Add Template Tags (Important step)
- Under Template tags, click Add new tag:
  - Key: Name
  - Value: app server instance (or the same name you previously used)
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn
- **Note**: These tags must match exactly with the tags used previously for consistency.

### Step 4: Select AMI (Application and OS Images)
- Under Application and OS Images:
  - Select My AMIs → Owned by me.
  - From the dropdown, select the previously created AMI intended for your App Server.

### Step 5: Select Instance Type
- Choose t2.micro from the dropdown menu.

### Step 6: Key Pair (login)
- Under Key pair name, select Don’t include in launch template.

### Step 7: Network Settings
- Leave these settings unchanged:
  - Subnet: Keep as Don’t include in launch template.
  - Security groups: Do not select any security group (leave blank).

### Step 8: Storage (Volumes)
- Do not make changes; keep the default storage settings.

### Step 9: Resource Tags (Important)
- Under Resource tags, click Add new tag:
  - Key: Name
  - Value: app server
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn

### Step 10: Advanced Details
- Under Advanced details, select AppServerIAMRole from the dropdown for IAM instance profile.
- Keep all other advanced settings at default (do not change anything else).

### Step 11: Create Launch Template
- Review your configuration carefully.
- Click Create launch template at the bottom.

---

## Creating an AMI for Web Server EC2 Instance

### Step 1: Navigate to EC2 Instances
- Log in to your AWS Management Console.
- Go to the EC2 service.
- Click on Instances in the sidebar.

### Step 2: Select Your Web Server Instance
- Select the Web Server EC2 instance you created earlier.
- Click on Actions → Hover over Image and templates → Select Create image.

### Step 3: Create Image Configuration
- In the new window (Create image), enter:
  - Image name: Provide a suitable name (e.g., WebServerAMI).
  - Image description: Enter a brief description (e.g., AMI for Web Server instance).
  - Reboot instance: Deselect this option to prevent instance reboot.

### Step 4: Storage Configuration
- Do not change the default storage settings. Leave them as-is.

### Step 5: Add Tags to the AMI (Important step)
- Under Tags section, click Add new tag:
  - Key: Name
  - Value: webserver-ami
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn

### Step 6: Create the AMI
- Review your details carefully.
- Click on Create image at the bottom of the page.

---

## Creating an AMI for App Server EC2 Instance

### Step 1: Navigate to EC2 Instances
- Log in to your AWS Management Console.
- Go to the EC2 service.
- From the sidebar, click Instances.

### Step 2: Select Your App Server Instance
- Select the App Server EC2 instance you previously created.
- Click on Actions → Hover over Image and templates → Choose Create image.

### Step 3: Configure Image Details
- In the Create image window, provide the following details:
  - Image name: Enter a suitable name (e.g., AppServerAMI).
  - Image description: Enter a brief description (e.g., AMI for Application Server instance).
  - Reboot instance: Deselect this option (to prevent the instance from rebooting during AMI creation).

### Step 4: Storage Configuration
- Leave storage settings at default (no changes needed).

### Step 5: Add Tags to AMI (Important step)
- Under Tags, click Add new tag:
  - Key: Name
  - Value: appserver-ami
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn

### Step 6: Create the AMI
- Carefully review the provided information.
- Click Create image at the bottom.

---

## Creating External Application Load Balancer (ALB) in Public Subnet

### Step 1: Navigate to Load Balancer Section in AWS Console
- Log in to the AWS Management Console.
- Select EC2 service.
- On the left sidebar, scroll down to Load Balancing, and click on Load Balancers.
- Click on the orange button labeled Create load balancer.

### Step 2: Choose Load Balancer Type
- You will see three types of load balancers (Application, Network, and Gateway).
- Select the Application Load Balancer (ALB) option.
- Click Create.

**Note**: ALB is ideal for web applications and microservices, routing traffic based on HTTP/HTTPS protocols.

### Step 3: Basic Configuration for ALB
- Load balancer name: Enter a meaningful name (e.g., ExternalALB).
- Scheme: Select Internet-facing
  - (Choose Internet-facing to expose the ALB publicly over the internet.)
- Load balancer IP address type: Keep default IPv4 selected.

### Step 4: Network Mapping (Important and Complex Step)
- VPC: Select the existing VPC you’ve previously created.
- Availability Zones and Subnets:
  - Select at least 3 Availability Zones for high availability.
  - Carefully select each Availability Zone (AZ) and from the dropdown menu, choose the corresponding Public subnet for that AZ.
  - Example:
    - AZ-1 → Public subnet in AZ-1
    - AZ-2 → Public subnet in AZ-2
    - AZ-3 → Public subnet in AZ-3

**Important**: Ensure each selected Availability Zone has a corresponding Public subnet selected to allow external internet access to your ALB.

### Step 5: Security Groups
- In the Security groups section, select the previously created security group specifically for your External ALB.
- Ensure that this security group allows incoming HTTP (port 80) traffic from the internet (0.0.0.0/0).

### Step 6: Listeners and Routing Configuration
- Configure listener settings:
  - Protocol: Select HTTP
  - Port: Enter 80
- Next, click Create target group (this will open in a new window/tab).

---

## Creating a Target Group (Detailed Instructions)

A Target Group defines where the ALB routes traffic.

### Step 6.1: Configure Target Group
- Target type: Select Instances (directing traffic to EC2 instances).
- Target group name: Enter a meaningful name (e.g., external-alb-tg).
- VPC: Select the existing VPC used earlier.
- Keep other configurations at default values.

### Step 6.2: Add Tags for Target Group (Important for Resource Management)
- Under Tags, click Add new tag:
  - Key: Name
  - Value: external-alb-tg
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn
- Click Next.

### Step 6.3: Register EC2 Instances to Target Group
- In the Available instances section:
  - Select your Web Server EC2 instance(s) intended to receive traffic.
  - Click Include as pending below.
- Confirm selected instances appear under Review targets.
- Finally, click Create target group.

✅ Target Group creation is now complete and ready for ALB routing.

### Step 7: Return to Load Balancer Creation Page
- Now, return to the previous Create Load Balancer tab/window.
- Under Default action (Listeners and routing), select your newly created external-alb-tg target group from the dropdown.

### Step 8: Add Tags to the Load Balancer (Important)
- Under Load balancer tags:
  - Click Add new tag:
    - Key: Name
    - Value: external-alb
  - Click Add new tag again:
    - Key: Environment
    - Value: cloudlearn

**Tip**: Tags help organize AWS resources, making management and billing easier.

### Step 9: Review and Create your External ALB
- Carefully review all configurations for accuracy.
- Confirm that:
  - Internet-facing scheme is selected.
  - 3 Availability Zones with Public subnets are correctly mapped.
  - Correct Security group is associated.
  - HTTP port 80 listener is correctly configured.
  - Correct target group is associated.
  - Tags (Name and Environment) are correctly added.
- Once reviewed, click the Create load balancer button at the bottom.

✅ Congratulations! Your External Application Load Balancer (ALB) is now successfully created in the public subnet and is ready to distribute incoming web traffic.

---

## Creating Internal Application Load Balancer (ALB) in Private Subnet <span id="Chapter2"><span>

### Step 1: Navigate to Load Balancer in AWS Console
- Log in to your AWS Management Console.
- Go to the EC2 service.
- In the sidebar, under Load Balancing, select Load Balancers.
- Click Create load balancer.

### Step 2: Choose Load Balancer Type
- Among the options, select Application Load Balancer (ALB).
- Click the Create button.

**Note**: ALB is suitable for internal traffic routing to your application servers (e.g., NodeJS).

### Step 3: Basic Configuration for Internal ALB
- Load balancer name: Enter a descriptive name (e.g., InternalALB).
- Scheme: Select Internal (this will make the ALB accessible only within your VPC).
- Load balancer IP address type: Leave the default setting (IPv4).

### Step 4: Network Mapping (Important and Complex Step)
- VPC: Select the existing VPC used earlier.
- Under Availability Zones and Subnets, select 3 Availability Zones (AZs), assigning private subnets for each AZ:
  - Example:
    - AZ-1 → Private subnet of AZ-1
    - AZ-2 → Private subnet of AZ-2
    - AZ-3 → Private subnet of AZ-3

**Important**: Ensure each AZ has a correctly selected corresponding private subnet. This ensures your Internal ALB remains accessible only internally.

### Step 5: Security Groups
- Under Security groups, select the existing security group you’ve previously created specifically for your Internal ALB (e.g., internal-alb-sg).
- Make sure this security group allows internal HTTP traffic (port 80) from your Web Server security group.

### Step 6: Listeners and Routing Configuration
- Set the following:
  - Protocol: HTTP
  - Port: 80
- Click Create target group (this opens in a new window/tab).

---

## Creating a Target Group for Internal ALB (Detailed Instructions)

A Target Group defines which servers your ALB will route requests to.

### Step 6.1: Configure Target Group
- Target type: Select Instances (traffic directed to EC2 App Server instances).
- Target group name: Enter a meaningful name (e.g., internal-alb-tg).
- VPC: Select your existing VPC.
- Leave all other settings at their default values.

### Step 6.2: Add Tags for Target Group (Important)
- Under Tags, click Add new tag:
  - Key: Name
  - Value: internal-alb-tg
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn
- Click Next.

### Step 6.3: Register Application Server Instances
- In the Available instances section:
  - Select your App Server EC2 instances.
  - Click Include as pending below.
- Confirm the selected instances appear under Review targets.
- Click Create target group.

✅ Target Group creation for your Internal ALB is now complete.

### Step 7: Return to Load Balancer Creation Page
- Return to the original Create load balancer tab.
- Under Default action (Listeners and routing), select your newly created internal-alb-tg from the dropdown.

### Step 8: Add Tags to Internal ALB (Important)
- Under Load balancer tags, click Add new tag:
  - Key: Name
  - Value: internal-alb
- Click Add new tag again:
  - Key: Environment
  - Value: cloudlearn

**Tip**: Adding tags helps you easily manage and identify AWS resources.

### Step 9: Review and Create your Internal ALB
- Carefully review all the configurations.
- Confirm the following:
  - Internal scheme is correctly set.
  - 3 Availability Zones with private subnets are properly selected.
  - Correct Security group (internal-alb-sg) is associated.
  - Listener configured for HTTP port 80.
  - Target group (internal-alb-tg) is correctly linked.
  - Tags (Name and Environment) properly added.
- After reviewing, click Create load balancer at the bottom.

✅ Your Internal Application Load Balancer (ALB) is now successfully created in the private subnet, securely routing internal traffic to your application servers.

---

## Creating Auto Scaling Group (ASG) for Web Server

### Step 1: Navigate to Auto Scaling Group in AWS Console
- Log into your AWS Management Console.
- Go to the EC2 service.
- On the left side panel, select Auto Scaling groups under the Auto Scaling section.
- Click the orange button labeled Create Auto Scaling group at the top-right corner.

### Step 2: Choose Launch Template (Important)
- Auto Scaling group name: Provide a clear, descriptive name (e.g., web-server-asg).
- Under Launch template, select your previously created Web Server Launch Template.
- For Version, keep the default version (usually Default).
- Click on Next to proceed.

### Step 3: Configure Instance Launch Options (Important)
- Launch template: Verify it’s showing your previously created Web Server Launch Template.
- Instance type: Confirm t2.micro (or desired type) is selected.

**Network Configuration (Critical)**
- Select your existing VPC.
- Under Availability Zones and subnets, select all Public Subnets from at least 3 Availability Zones (essential for high availability):
  - Example:
    - AZ-1 → Public subnet
    - AZ-2 → Public subnet
    - AZ-3 → Public subnet

**Important Note**: Selecting all three public subnets across different AZs ensures high availability for your web server instances.

- Ensure Balanced best effort is selected under Availability Zone distribution.
- Click on Next to proceed.

### Step 4: Integrate with Existing Load Balancer (Important)
- Select the option Attach to an existing load balancer.
- Under Existing load balancer target groups, select your previously created External ALB target group (e.g., external-alb-tg) from the dropdown.
- Under the Health checks section, make sure to enable (check) the box:
  - Turn on Elastic Load Balancing health checks (to ensure only healthy instances handle traffic).
- Click Next to proceed.

### Step 5: Configure Group Size and Scaling (Critical Step)

#### Step 5.1: Group Size (Initial Capacity)
- Desired capacity: Enter initial number of EC2 instances (e.g., 2) to start your ASG.

#### Step 5.2: Scaling Limits Configuration
- Define the scaling range:
  - Minimum desired capacity: Enter minimum instances you want (e.g., 1).
  - Maximum desired capacity: Enter maximum instances to scale up to (e.g., 4).

### Step 6: Automatic Scaling (Dynamic Scaling Policy)
- Choose Target tracking scaling policy (recommended for automatic scaling).
- Scaling policy name: Enter a policy name or keep default (e.g., Target Tracking Policy).
- Metric type: Select Average CPU utilization from dropdown (most common for web traffic).
- Set the Target value to 90 (instances scale out/in based on 90% CPU usage).
- Keep other settings (Instance warmup, etc.) as defaults.
- Click Next to proceed.

### Step 7: Notifications
- Keep default settings (No notifications needed).
- Click Next to proceed.

### Step 8: Add Tags (Important Step)
- Click Add tag:
  - Key: Name
  - Value: web-server-asg
- Click Add tag again:
  - Key: Environment
  - Value: cloudlearn
- Ensure both tags have Tag new instances enabled (checkbox should be checked).
- Click Next.

**Important**: These tags help manage and identify your Auto Scaling instances clearly within AWS.

### Step 9: Review & Create Auto Scaling Group (ASG)
- Carefully review your configuration:
  - Confirm Launch Template details.
  - Check Network Configuration: Public subnets and AZ settings.
  - Verify correct attachment to External ALB Target Group.
  - Confirm scaling policies and tagging information are accurately configured.
- Click Create Auto Scaling group at the bottom.

✅ Your Auto Scaling Group for the Web Server is now successfully created. It will automatically manage your Web Server EC2 instances, scaling them based on your defined policies and health checks.

---

## Creating Auto Scaling Group (ASG) for App Server

### Step 1: Navigate to Auto Scaling Groups in AWS Console
- Log into your AWS Management Console.
- Open the EC2 service.
- From the left sidebar, click on Auto Scaling groups.
- Click on the Create Auto Scaling group button (top-right corner).

### Step 2: Choose Launch Template
- Auto Scaling group name: Provide a meaningful name (e.g., app-server-asg).
- Under Launch template, select your previously created App Server Launch Template.
- Leave Version as default.
- Click on Next to proceed.

### Step 3: Choose Instance Launch Options (Important)

**Instance Type and Network Configuration:**
- Instance type: Default (e.g., t2.micro) inherited from your launch template.
- VPC: Select the previously created VPC.
- Under Availability Zones and subnets, select all Private Subnets across at least 3 Availability Zones:
  - Example:
    - AZ-1 → Private subnet
    - AZ-2 → Private subnet
    - AZ-3 → Private subnet

**Important**: Always ensure the subnets selected here are private for internal security.

- Keep the Availability Zone distribution set to Balanced best effort (default option).
- Click Next to proceed.

### Step 4: Integrate with Internal Load Balancer (Important Step)
- Under Load balancing, select Attach to an existing load balancer.
- Select Choose from your load balancer target groups.
- From the dropdown, select your previously created Internal ALB Target Group (e.g., internal-alb-tg).

**Configure Health Checks:**
- Under health check settings, enter 300 for Health check grace period.
- Click Next to proceed.

### Step 5: Configure Group Size and Scaling (Critical)

#### Step 5.1: Set Desired Capacity
- Desired capacity: Enter 2 (initially two instances).

#### Step 5.2: Scaling Limits
- Minimum desired capacity: Enter 1
- Maximum desired capacity: Enter 4

**Automatic Scaling (Optional but recommended)**
- Select Target tracking scaling policy.
- Keep default Scaling policy name or enter a custom name (e.g., Target Tracking Policy).
- For Metric type, select Average CPU utilization.
- Set Target value as 90 (ensures auto-scaling based on CPU usage threshold).
- Click Next.

### Step 6: Notifications (Optional)
- Skip notifications settings (leave default unless notifications are explicitly required).
- Click Next.

### Step 7: Add Tags (Important Step)
- Click Add tag:
  - Key: Name
  - Value: app-server-asg
- Click Add tag again:
  - Key: Environment
  - Value: cloudlearn
- Confirm the option Tag new instances is enabled (checked).
- Click Next.

### Step 8: Review and Create ASG
- Carefully review your configuration details:
  - ASG Name and Launch template correctly selected.
  - Verify the selected private subnets and Availability Zones.
  - Confirm Internal ALB Target Group attachment.
  - Ensure Scaling policies, Health checks, and Tagging are correctly configured.
- Once everything is reviewed, click Create Auto Scaling group at the bottom.

✅ Congratulations! Your Auto Scaling Group for the Application Server is successfully created in private subnets, managing internal app instances efficiently and securely.

---

## Step-by-Step Instructions for Opening Ports from External ALB Security Group to Web Server Security Group (Securely)

**Objective**: Configure secure port openings between the External ALB Security Group and the Web Server Security Group to ensure controlled access while maintaining security best practices.

### Step 1: Navigate to the Security Groups in AWS Console
1. Log into the AWS Management Console.
2. Open the EC2 service.
3. In the left-side menu, under Network & Security, click on Security Groups.

### Step 2: Identify and Select the External ALB Security Group
1. Find the External ALB Security Group that is associated with your External Application Load Balancer (ALB).
2. Click on the Security Group ID to open its details.

### Step 3: Modify Inbound Rules for the Web Server
1. Click on the Inbound Rules tab.
2. Click the Edit inbound rules button.
3. Click Add Rule and configure the following:
   - Type: HTTP
   - Protocol: TCP
   - Port Range: 80
   - Source: Select Custom → Choose the Web Server Security Group ID
     - (This ensures that only traffic from ALB to the web server is allowed.)
4. Click Add Rule again to add another rule for HTTPS (if needed):
   - Type: HTTPS
   - Protocol: TCP
   - Port Range: 443
   - Source: Select Custom → Choose the Web Server Security Group ID
     - (This ensures secure traffic is passed through HTTPS.)
5. Click Save rules to apply changes.

### Step 4: Verify Web Server Security Group Rules
1. Go back to Security Groups.
2. Select the Web Server Security Group.
3. Click on the Inbound Rules tab and verify:
   - There is no direct open access from the internet (0.0.0.0/0 or ::/0).
   - It should only allow HTTP (80) and HTTPS (443) traffic from the External ALB Security Group.

### Step 5: Test the Connection
1. Deploy an instance in the Web Server Auto Scaling Group.
2. Ensure it is properly receiving traffic through the ALB.
3. Use the ALB DNS Name in a browser to confirm that the web server is accessible.

**Security Best Practices**
- ✔ Never open HTTP/HTTPS traffic directly from the internet (0.0.0.0/0) to the Web Server Security Group.
- ✔ Always use Security Group references (instead of IPs) to allow communication between ALB and Web Server.
- ✔ Enable HTTPS for encrypted traffic instead of HTTP when possible.
- ✔ Use AWS WAF (Web Application Firewall) for additional security if required.

✅ You have now securely allowed External ALB traffic to communicate with the Web Server while maintaining best security practices.

---

## Step-by-Step Instructions for Opening Ports from Web Server Security Group to Internal ALB Security Group (Securely)

**Objective**: Configure secure port openings between the Web Server Security Group and the Internal ALB Security Group to ensure controlled access while maintaining security best practices.

### Step 1: Navigate to Security Groups in AWS Console
1. Log into the AWS Management Console.
2. Open the EC2 service.
3. On the left sidebar, under Network & Security, click on Security Groups.

### Step 2: Identify and Select the Web Server Security Group
1. Find the Web Server Security Group that is associated with your Web Server Auto Scaling Group.
2. Click on the Security Group ID to open its details.

### Step 3: Modify Outbound Rules for Secure Communication
1. Click on the Outbound Rules tab.
2. Click the Edit outbound rules button.
3. Click Add Rule and configure the following:
   - Type: HTTP
   - Protocol: TCP
   - Port Range: 80
   - Destination: Select Custom → Choose the Internal ALB Security Group ID
     - (This ensures that only traffic from the Web Server to the Internal ALB is allowed.)
4. Click Add Rule again to add another rule for HTTPS (if needed):
   - Type: HTTPS
   - Protocol: TCP
   - Port Range: 443
   - Destination: Select Custom → Choose the Internal ALB Security Group ID
     - (This ensures secure traffic is passed through HTTPS.)
5. Click Save rules to apply changes.

### Step 4: Modify Inbound Rules for Internal ALB Security Group
1. Go back to Security Groups.
2. Select the Internal ALB Security Group.
3. Click on the Inbound Rules tab.
4. Click Edit inbound rules and Add Rule:
   - Type: HTTP
   - Protocol: TCP
   - Port Range: 80
   - Source: Select Custom → Choose the Web Server Security Group ID
     - (Ensures the ALB only accepts traffic from the Web Servers.)
5. Click Add Rule again for HTTPS (if applicable):
   - Type: HTTPS
   - Protocol: TCP
   - Port Range: 443
   - Source: Select Custom → Choose the Web Server Security Group ID
     - (Ensures encrypted traffic between Web Server and Internal ALB.)
6. Click Save rules to apply changes.

### Step 5: Verify Security Group Rules
1. Ensure the Web Server Security Group does not allow direct outbound internet access (0.0.0.0/0 or ::/0) unless explicitly needed.
2. Ensure the Internal ALB Security Group only allows traffic from the Web Server Security Group (not open to the internet).

### Step 6: Test the Connection
1. Deploy an instance in the Web Server Auto Scaling Group.
2. Verify that it can communicate with the Internal ALB by making an HTTP request.
3. Use logs, monitoring, or AWS VPC Flow Logs to confirm that traffic is flowing securely.

**Security Best Practices**
- ✔ Never allow open inbound/outbound traffic from 0.0.0.0/0 or ::/0 unless absolutely necessary.
- ✔ Always use Security Group references instead of IPs for controlled access.
- ✔ Ensure Web Servers can only communicate with the Internal ALB, not the internet directly.
- ✔ Use AWS WAF (Web Application Firewall) for added security, if needed.

✅ You have now securely allowed Web Server instances to communicate with the Internal ALB, maintaining a structured and secure network architecture.

---

## Step-by-Step Instructions for Opening Ports from Internal ALB Security Group to App Server Security Group (Securely)

### Step 1: Navigate to Security Groups in AWS Console
1. Log into the AWS Management Console.
2. Open the EC2 service.
3. In the left sidebar, under Network & Security, click on Security Groups.

### Step 2: Identify and Select the Internal ALB Security Group
1. Locate the Internal ALB Security Group that is associated with your Internal Application Load Balancer (ALB).
2. Click on the Security Group ID to open its details.

### Step 3: Modify Outbound Rules to Allow Secure Traffic to App Server
1. Click on the Outbound Rules tab.
2. Click the Edit outbound rules button.
3. Click Add Rule and configure the following:
   - Type: HTTP
   - Protocol: TCP
   - Port Range: 80
   - Destination: Select Custom → Choose the App Server Security Group ID
     - (This ensures that only traffic from the Internal ALB to the App Server is allowed.)
4. Click Add Rule again to add another rule for HTTPS (if needed):
   - Type: HTTPS
   - Protocol: TCP
   - Port Range: 443
   - Destination: Select Custom → Choose the App Server Security Group ID
     - (This ensures secure traffic is passed through HTTPS.)
5. Click Save rules to apply changes.

### Step 4: Modify Inbound Rules for App Server Security Group
1. Go back to Security Groups.
2. Select the App Server Security Group.
3. Click on the Inbound Rules tab.
4. Click Edit inbound rules and Add Rule:
   - Type: HTTP
   - Protocol: TCP
   - Port Range: 80
   - Source: Select Custom → Choose the Internal ALB Security Group ID
     - (Ensures the App Server only accepts traffic from the Internal ALB.)
5. Click Add Rule again for HTTPS (if applicable):
   - Type: HTTPS
   - Protocol: TCP
   - Port Range: 443
   - Source: Select Custom → Choose the Internal ALB Security Group ID
     - (Ensures encrypted traffic between Internal ALB and App Server.)
6. Click Save rules to apply changes.

### Step 5: Verify Security Group Rules
1. Ensure the Internal ALB Security Group does not allow open outbound access to the internet (0.0.0.0/0 or ::/0).
2. Ensure the App Server Security Group only allows traffic from the Internal ALB Security Group (not open to the internet).

### Step 6: Test the Connection
1. Deploy an instance in the App Server Auto Scaling Group.
2. Verify that it can receive traffic from the Internal ALB by making an HTTP request.
3. Use monitoring tools like AWS CloudWatch or VPC Flow Logs to ensure the traffic flow is secure.

**Security Best Practices**
- ✔ Never allow open inbound/outbound traffic from 0.0.0.0/0 or ::/0 unless explicitly needed.
- ✔ Always use Security Group references instead of static IPs for controlled access.
- ✔ Ensure App Servers can only communicate with the Internal ALB, not the internet directly.
- ✔ Use AWS WAF (Web Application Firewall) for additional security if required.

✅ You have now securely configured port openings from the Internal ALB to the App Server while maintaining a secure and structured network architecture.

---
## Configure secure port openings between the App Server Security Group and the Database (DB) Security Group to ensure controlled access while maintaining best security practices.  <span id="Chapter1"><span>

## Step 1: Navigate to Security Groups in AWS Console

1. Log into the AWS Management Console.
2. Open the EC2 service.
3. In the left sidebar, under Network & Security, click on **Security Groups**.

## Step 2: Identify and Select the App Server Security Group

1. Locate the App Server Security Group that is associated with your App Server Auto Scaling Group.
2. Click on the Security Group ID to open its details.

## Step 3: Modify Outbound Rules to Allow Secure Traffic to DB Instance

1. Click on the **Outbound Rules** tab.
2. Click the **Edit outbound rules** button.
3. Click **Add Rule** and configure the following:
   - **Type**: MySQL/Aurora (or choose the database type you are using)
   - **Protocol**: TCP
   - **Port Range**: 3306 (for MySQL)
     - (If using PostgreSQL, enter 5432 instead.)
   - **Destination**: Select **Custom** → Choose the DB Instance Security Group ID
     - (Ensures only App Server instances can communicate with the DB.)
4. Click **Save rules** to apply changes.

## Step 4: Modify Inbound Rules for DB Instance Security Group

1. Go back to **Security Groups**.
2. Select the DB Instance Security Group.
3. Click on the **Inbound Rules** tab.
4. Click **Edit inbound rules** and **Add Rule**:
   - **Type**: MySQL/Aurora (or the appropriate database type)
   - **Protocol**: TCP
   - **Port Range**: 3306 (For MySQL/Aurora)
     - (For PostgreSQL, enter 5432.)
   - **Source**: Select **Custom** → Choose the App Server Security Group ID
     - (Ensures the DB only accepts connections from the App Server instances.)
5. Click **Save rules** to apply changes.

## Step 5: Verify Security Group Rules

1. Ensure the DB Security Group does not allow open access (0.0.0.0/0 or ::/0).
2. Ensure the App Server Security Group only allows outbound connections to the DB.
3. Double-check that no inbound access is allowed from the internet to the DB Instance.

## Step 6: Test the Connection

1. Log in to an App Server instance.
2. Try connecting to the DB Instance using a MySQL/PostgreSQL client:
   ```bash
   mysql -h <db-endpoint> -u <db-user> -p
   ```
  -  Replace "db-endpoint" with the RDS instance endpoint.
  - Replace "db-user" with the database user.
3. If the connection is successful, traffic is properly routed.

**Security Best Practices**
- ✔ Never allow inbound access from 0.0.0.0/0 or ::/0 to your Database.
- ✔ Always use Security Group references instead of static IPs for controlled access.
- ✔ Ensure App Servers can only communicate with the DB Instance, not the internet directly.
- ✔ Enable AWS RDS Encryption and IAM authentication for added security if applicable.

✅ You have now securely configured port openings from the App Server to the DB Instance while maintaining a highly secure and structured network architecture.

# Step-by-Step Instructions for Opening Port 80 from the Internet to External ALB (Securely)

Configure secure port opening to allow public HTTP traffic (port 80) from the internet to reach the External Application Load Balancer (ALB) while ensuring security best practices.

## Step 1: Navigate to Security Groups in AWS Console

1. Log into the AWS Management Console.
2. Open the EC2 service.
3. In the left sidebar, under **Network & Security**, click on **Security Groups**.

## Step 2: Identify and Select the External ALB Security Group

1. Locate the External ALB Security Group associated with your External ALB.
2. Click on the Security Group ID to open its details.

## Step 3: Modify Inbound Rules to Allow Public HTTP Traffic

1. Click on the **Inbound Rules** tab.
2. Click the **Edit inbound rules** button.
3. Click **Add Rule** and configure the following:
   - **Type**: HTTP
   - **Protocol**: TCP
   - **Port Range**: 80
   - **Source**: Select **Anywhere-IPv4** (0.0.0.0/0)
     - (This allows traffic from the public internet.)
4. Click **Save rules** to apply changes.

## Step 4: Verify Security Group Rules

1. Ensure only HTTP (port 80) is open to the public.
2. If HTTPS (port 443) is also needed, repeat Step 3 but choose HTTPS instead of HTTP.
3. Do not allow unrestricted access to any other ports from 0.0.0.0/0 (except 443 for HTTPS if needed).

## Step 5: Test Public Access

1. Copy the DNS Name of your External ALB.
2. Open a web browser and enter:
    ```bash
   http://<ALB-DNS-Name>
   ```
3. If properly configured, the ALB should forward requests to the Web Server.

## Security Best Practices

- ✔ Do not expose other ports (e.g., SSH, database ports) to the public internet.
- ✔ For production environments, always use HTTPS (port 443) with an SSL certificate instead of HTTP.
- ✔ Consider using AWS WAF (Web Application Firewall) for additional protection.
- ✔ Restrict access to trusted IPs if necessary using CIDR ranges.

✅ You have now securely configured port 80 to allow public HTTP traffic to reach the External ALB while following security best practices.
