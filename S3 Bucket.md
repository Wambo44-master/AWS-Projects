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


## Congratulations!!
