provider "boundary" {
  addr                            = "http://127.0.0.1:9200"  // Replace it with any ip where you wish to run the boundary
  auth_method_id                  = "ampw_RSAd1iRj1Q"        // Replace it with your auth id
  password_auth_method_login_name = "superadmin"             // Replace it with your login id
  password_auth_method_password   = "password"               // Replace it with your password
}

resource "boundary_scope" "org" {                            // This step creates the org on the boundary so replace as per the requirements
  name                     = "sarva"                         // specify the name you wish
  description              = "My first scope!"
  scope_id                 = "global"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_auth_method" "password" {                // This method tells the auth method to use like boundary supports two types of
  scope_id = boundary_scope.org.id                          // auth method password and OIDC. Here in this code we are using the password
  type     = "password"                                     // method
}

resource "boundary_account_password" "niyog" {              // This method is used to create the accounts for users which is created in the     
  auth_method_id = boundary_auth_method.password.id         // next step
  type           = "password" 
  login_name     = "niyog"                                  
  password       = "password"
}

resource "boundary_account_password" "manish" {              // This method is used to create the accounts for users which is created in the     
  auth_method_id = boundary_auth_method.password.id         // next step
  type           = "password"
  login_name     = "manish"
  password       = "password"
}

resource "boundary_user" "niyog" {                          // This method is used to create the users and assign the accounts which created 
  name        = "niyog"                                     // in the previous step and user can login using this cred
  account_ids = [boundary_account_password.niyog.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_user" "manish" {                          // This method is used to create the users and assign the accounts which created 
  name        = "manish"                                     // in the previous step and user can login using this cred
  account_ids = [boundary_account_password.manish.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_scope" "project" {                       // This method is used to create the project under the org which we created in the earlier stage
  name                   = "MOI"                    
  scope_id               = boundary_scope.org.id
  auto_create_admin_role = true
}

resource "boundary_host_catalog_static" "example" {         // This method is used to create the host-catalog under the project which we 
  name        = "My catalog"                                // created in the previous step host-catalog is created based on the type of VM it might be staic or dynamic
  scope_id    = boundary_scope.project.id
}

resource "boundary_host_catalog_static" "example1" {         
  name        = "My catalog1"                                
  scope_id    = boundary_scope.project.id
}

resource "boundary_host_static" "demo" {                    // This method is used to create the hosts under the host-catalog
  name            = "example_host"                          
  address         = "10.0.0.1"
  host_catalog_id = boundary_host_catalog_static.example.id
}

resource "boundary_host_static" "demo1" {                    
  name            = "example_host1"                          
  address         = "10.0.0.1"
  host_catalog_id = boundary_host_catalog_static.example1.id
}

resource "boundary_role" "editor" {                       // This method is used to assign the roles and permissions, using this the boundary
  name          = "editor"                                // checks whether the user has an appropriate role or not for accessing host-catalog and targets
  principal_ids = [boundary_user.niyog.id]
  grant_strings = ["type=host-catalog;actions=list",
                   "id=${boundary_host_catalog_static.example.id};actions=read",
                   "id=${boundary_host_catalog_static.example.id};type=host;actions=read,list"]
  scope_id      = boundary_scope.project.id
}

resource "boundary_role" "editor1" {                       // This method is used to assign the roles and permissions, using this the boundary
  name          = "editor1"                                // checks whether the user has an appropriate role or not for accessing host-catalog and targets
  principal_ids = [boundary_user.manish.id]
  grant_strings = ["type=host-catalog;actions=list",
                   "id=${boundary_host_catalog_static.example1.id};actions=read",
                   "id=${boundary_host_catalog_static.example1.id};type=host;actions=read,list"]
  scope_id      = boundary_scope.project.id
}
