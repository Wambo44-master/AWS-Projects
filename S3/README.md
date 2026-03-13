<details>
<summary>📂 <b>Click here to see the M-Pesa 10-Year Case Study Solution</b></summary>

### The Business Challenge
A company wants to store M-Pesa transactions dating back 10 years. It's headquarters are in Nairobi but they have auditors in various locations worldwide. The data is accessed randomly but must be retrieved quickly. The company must also comply to the law that data identical copies of the data should be in geographically distinct locations.

### My Solution
* **Multi-Region:** Enabled Cross-Region Replication (CRR).
* **Cost Saving:** Configured Lifecycle Rules to move data to Glacier Instant Retrieval after 1 year.
* **Random Access:** Used S3 Intelligent-Tiering to handle unpredictable data retrieval.
* **Latency:** Used Multi Region Access Point.
* **Costs**

</details>

## Create an S3 Bucket and store objects

## Objectives
1. Create an S3 Bucket
2. Upload objects to the bucket
3. Make an object public
4. Create a bucket policy


### Define best practices to secure S3 buckets:
1. Define explicit permissions for bucket access.
2. Ensure public access to objects and bu ckets is blocked unless explicitly permitted.
3. Grant users access based on least privilege.
4. Use S3 access logs to monitor suspicious activity.

## Create a bucket
1. Login to the AWS Management Console and search for S3 and select it.
2. On the S3 Dashboard, select create a bucket.
3. Give your bucket a name. **NOTE: This must be globally unique.
4. Select your choice of object ownership i.e a).is owned solely by you(ACLS disabled) or b).can be owned by other AWS accounts(ACLS enabled).
5. Choose whether to make your bucket public or private. **NOTE blocking public access is recommended and is the default setting.
6. Choose whether or not to enable versioning. **NOTE enables storing multiple variants of an object in a single bucket, allowing you to preserve, retrieve, and restore every version of an object.
7. Choose your preferred encryption type. **NOTE encryption is automatically applied to any objects uploaded to your bucket.
8. Create your bucket.

## Uploading objects to your bucket
1. In the S3 management console, select your bucket.
2. Choose upload which launches an upload wizard.
3. Select files from your preferred source or drag and drop to the S3 window.
4. Add the selected file(s) and select upload.
5. A green bar notification pops up when the upload is successful.

## Make buckets public
1. Select the bucket you created.
2. Choose the Permissions tab
3. Under bucket settings, select Block Public Access, edit and deselect the block all public access option.
4. Save your changes.

## Making objects public(if you retained the option to block all public access during bucket creation)
1. In the overview page of your bucket, select a file you uploaded.
2. Select object actions and select Make public using ACL.
3. Choose make public at the bottom of the page.
4. To confirm public access, in the objects tab of your bucket, copy the Object URL and paste in a new window and you should see the contents.

## Create a bucket policy using AWS Policy generator.
1. Search for IAM and select Roles.
2. Select the role you want to grant users access to and copy the Role ARN.
3. Head back to S3 Management Console.
4. Choose your bucket and select the Permissions tab.
5. Scroll to the Bucket Policy Section and choose edit.
6. Read through the permissions or check if it is blank.
7. Open a new tab and go to AWS Policy Generator.
8. Select : - Select S3 Bucket Policy
            - Effect = Allow
            - Principal - Paste the role ARN you had copied
            -Actions -  Select what access to grant to users
            - Resource -  Choose the resource
* NOTE: if your resource is a bucket ARN, add /* at the end to apply the policy to all objects in the bucket.
9. Add Statement and generate policy.
10. Copy the policy and paste it in your bucket policy editor.

This updates the permissions for your bucket


# 2. S3 Storage Classes
These are offered by S3 based on data access patterns and cost requirements.
* S3 Standard - Default storage class for frequently accessed data with low latency and high throughput performance. It is designed to deliver 99.99% availability.
* S3 Intelligent tiering - It reduces storage costs by automatically moving data to the most cost effective access tier based on frequency of access without affecting performance, retrieval fees or operational overhead.
* S3 Express One Zone - High performance, single-digit millisecond data access for most frequently accessed data. Reduces cost by 80% compared to S3 Standard however is in a specific AWS Availability Zone in an AWS region. Delivers 99.95% availability.
* Amazon S3 Standard Infrequent Access - Designed for data that is less frequently accessed but requires rapid access when needed. It offers high durability, high throuput and low latency of S3 Standard.Acts as a data store for disaster recovery files. Offers 99.99% availability.
* Amazon S3 One Zone-Infrequent Access - Designed for data that is less frequently accessed but can be rapidly accessed. It costs 20% less than S3 Stanard-IA. It is designed for cutomers who do not require the availability and resilience of S3 Standard and S3 Standard-IA. Delivers 99.5% availability.
* Amazon S3 Glacier Instant Retrieval - It is an archive storage class that delivers lowest cost storage for data that is rarely accessed but requires millisecond retrieval. It saves 68% compared to Standard-IA. Delivers 99.9% availability.
* Amazon S3 Glacier Flexible Retrieval - An archive storage class that delivers low cost storage that is 10% lower than S3 Glacier Instant Retrieval for data accessed 1 -2 times per year. Designed for 11 9's of data durability and 99.99% availability. Best for data that does not need immediate access but needs flexibility to retrieve large amounts of data at no cost.Retrieval time is Expedited :1–5 minutes (for urgent data), Standard 3–5 hours (for general retrieval) and Bulk: 5–12 hours (for large amounts of data at no cost).
* Amazon S3 Glacier Deep Archive - Offers the lowest cost storage and supports long term retention for data rarely accessed. Designed for companies that retain datasets for 7 - 10 years or more for regulatory compliance. Delivers 99.99% availabilty and the retrieval time is within 12 hours.

# M-Pesa Business Case
A company wants to store M-Pesa transactions dating back 10 years. It's headquarters are in Nairobi but they have auditors in various locations worldwide. The data is accessed randomly but must be retrieved quickly. The company must also comply to the law that data identical copies of the data should be in geographically distinct locations.

## Solution:
* Amazon S3 Intelligent Tiering - This will handle random access without affecting performance as the the first three tiers(Frequent, Infrequent and Archive Instant Access) provide the same millisecond latency as S3 Standard. If data remains inaccessed after 30 days, it automatically moves to Infrequent tier and is moved to Archived Instant after 90 days of no access. Once data is accessed, it is moved to the Frequent Access Tier automatically at no additional cost. **NOTE: S3 Intelligent Tiering does NOT auto tier objects smaller than 128 KB. Therefore it is important to bundle the M-Pesa Transactions into larger daily files to ensure tiering occurs.
In case data remains inaccessed for a year, it is important to configure a lifecyle policy that automatically moves data to Glacier Deep Archive.

* Cross Region Replication -  This is required especially with the compliance law that identical copies must be stored in different geographical locations. This can only be done if you have a source ucket and destination bucket in different AWS regions. Versioning MUST be enabled.

Steps:
* Navigate to the S3 Management Console.
* Create  a replication rule in the Replication Rules section and create a replication rule with a descriptive name e.g M-Pesa-Replication.
* Define the scope of the rule by choosing apply the rule to all objects in the bucket.
* Select the destination. Choose the Bucket in this account or in a different account and select ypur destination bucket.
* Configure Permissions. Go to IAM Role and choose create new role. S3 automatically generates a role with necessary permissions to read from the source and write to the destination on your behalf.

Standard CRR only replicates new objects. To upload existing data history, S3 Batch Replication is used. After saving your replication rule, AWS prompts you to replicate existing objects, select 'Yes' and this triggers a one-time Batch Operations for your existing data.

* Global Access using Multi Region Access Point (MRAP) - 
This provides a single global endpoint to reduce latency and workers use one fixed URL regardless of their physical location.
Steps:
* Navigate to S3 console and select Multi-Region Access Points from the left menu.
* Select 'Create Multi-Region Access Point' and provide a unique name.
* Add the bucket(s) used to store the M-Pesa Transactions.
* Once MRAP is 'ready', go to the 'Replication and Failover' tab and click 'Create replication rules' and select the template 'Replicate objects among all specified buckets'.
* Select all the buckets that will be used and choose to apply the rule to all objects.
* Copy the MRAP ARN and users will use this instead of the regional bucket URLs. This achieves lowest network latency.

* Object Lock. This prevents objects from being deleted or overwritten permanently or for a time of your choosing.

 Steps:
* Navigate to your S3 bucket and go to the Properties tab and scroll to 'Object Lock'.
* Select 'Edit' and select 'Enable'.

  ## Costs
  Based on the current conversion rate.
  
1. Storage costs
In S3 Intelligent Tiering, the costs are determined by which tier your data resides.
* Frequent Access - KES 2.99 ($0.023) per GB.
* Infrequent Access - KES 1.63 ($0.0125) per GB.
* Archive Instant Access - KES 0.52 ($0.004) per GB.

2. Data Movement and Replication
One time data transfer fee.
To move data from Nairoi for cross region replication, a one time fee of KES 2.60 ($0.02) per GB. Storage will be paid for in other regions so you may store your identical copy in a lower storage class for lower costs.

3. Global Access
This is triggered when the data is accessed globally.
* MRAP Routing - KES 0.43 ($0.0033) per GB.
* Data Transfer Out - KES 11.70($0.09) per GB.

4. Monitoring
* Intelligent Tiering Monitoring - KES 0.33 ($0.0025) per 1k objects.
  
