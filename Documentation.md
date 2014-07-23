# Documentation

# Example

1. When you have an already existed project:
  1. Go to Project Settings and in Modules tab select Default Issues
  ![](https://raw.githubusercontent.com/efigence/redmine_default_issues_images/master/PIC/Module_in_settings.png)
  2. Now you can see new tab in project menu                                                                                                       ![](https://raw.githubusercontent.com/efigence/redmine_default_issues_images/bfb909c64fe60992ee1c74765ebd41b4ab48d5db/PIC/empty_list.png)
  3. Lets start created new default issue for specified role
  ![](https://raw.githubusercontent.com/efigence/redmine_default_issues_images/master/PIC/form.png)
  4. There is example list of created defautl issues for specified role:
  ![](https://raw.githubusercontent.com/efigence/redmine_default_issues_images/bfb909c64fe60992ee1c74765ebd41b4ab48d5db/PIC/list_of_issues.png)
  5. In current Defautl Issue you can set relation to other (already existed) default issue:
  ![](https://raw.githubusercontent.com/efigence/redmine_default_issues_images/master/PIC/relation.png)
  6. New Default Issue can be sub Default Issue only in the same role. So when you will create new one, in subproject of: select subject of parent default issue
  ![](https://raw.githubusercontent.com/efigence/redmine_default_issues_images/master/PIC/subdefaultissue.png)
  7. If you already finished create Default Issues for specified role, you can add to your project some members/groups 
  8. After add members or groups to your project open tab of Issues and you can see that issues was generated from default issues with everithing
what you set in default issue(relations, trees, ...) for members with current role in project
  ![](https://raw.githubusercontent.com/efigence/redmine_default_issues_images/master/PIC/issue_list1.png)

2. If you start create a new project then you can select from Modules - Default Issues module

3. If you select 'inherit members' in new subproject then Default Issue which you will create in subproject and parent project for the same roles and add members to main project (parent), Issues will be create from Default Issue for project, subproject .. (only for themselves)

4. Permissions 
  1. You can specify which role will be able to CRUD an default issues in Administration/roles and permissions/'selected role' or in permission raport
  ![](https://raw.githubusercontent.com/efigence/redmine_default_issues_images/master/PIC/permission_raport_with_DF.png)

5. Newly added Member to project will have already genereted Issues from Default Issues for his role.
