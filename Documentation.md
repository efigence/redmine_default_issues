# Documentation
Here you can see documenation of usage [Redmine Default Issue Plugin][bb] step by step:
[bb]: https://github.com/efigence/redmine_default_issues


### When you have an already existed project:

  1. Go to Project Settings and in Modules tab select Default Issues
   ![](https://raw.githubusercontent.com/efigence/redmine_plugins_cdn/master/PIC/default_issue_plugin/Module_in_settings.png)
  2. Now you can see new tab in project menu
   ![](https://raw.githubusercontent.com/efigence/redmine_plugins_cdn/master/PIC/default_issue_plugin/empty_list.png)
  3. Lets start created new default issue for specified role
   ![](https://raw.githubusercontent.com/efigence/redmine_plugins_cdn/master/PIC/default_issue_plugin/form.png)
  4. There is example list of created defautl issues for specified role:
   ![](https://raw.githubusercontent.com/efigence/redmine_plugins_cdn/master/PIC/default_issue_plugin/list_of_issues.png)
  5. In current Defautl Issue you can set relation to other (already existed) default issue:
   ![](https://raw.githubusercontent.com/efigence/redmine_plugins_cdn/master/PIC/default_issue_plugin/relation.png)
  6. New Default Issue can be sub Default Issue only in the same role. So when you will create new one, in subproject of: select subject of parent default issue


![](https://raw.githubusercontent.com/efigence/redmine_plugins_cdn/master/PIC/default_issue_plugin/subdefaultissue.png)
### Issue will be create automatically
  7. If you already finished create Deault Issues for specified role, you can add to your project some members/groups 
  8. After add members or groups to your project open tab of Issues and you can see that issues was generated from default issues with everithing what you set in default issue(relations, trees, ...) for members with current role in project
   ![](https://raw.githubusercontent.com/efigence/redmine_plugins_cdn/master/PIC/default_issue_plugin/issue_list1.png)


### When you don't have an project: 
 If you start create a new project then you can select from Modules - Default Issues module

### Subproject - Inherit Members
  If you select 'inherit members' in new subproject then Default Issue which you will create in subproject and parent project for the same roles and add members to main project (parent), Issues will be create from Default Issue for project, subproject .. (only for themselves)

###  Permissions 
  1. You can specify which role will be able to CRUD an default issues in Administration/roles and permissions/'selected role' or in permission raport
  ![](https://raw.githubusercontent.com/efigence/redmine_plugins_cdn/master/PIC/default_issue_plugin/permission_raport_with_DF.png)

### Newly added Member to project will have already genereted Issues from Default Issues for his role.
