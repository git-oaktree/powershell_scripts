$Users = Import-Csv  -Path "C:\Users\Administrator\Desktop\bulk_user_import.csv"   
foreach ($User in $Users)            
{            
    #DC
    $Displayname = $User.GivenName + " " + $User.SurName            
    $UserFirstname = $User.GivenName            
    $UserLastname = $User.SurName            
    $OU = $User.Path           
    $SAM = $User.SAM            
    $UPN = $User.GivenName + "." + $User.SurName + "@" + "spiderweb.local"            
    $Description = $User.Description            
    $Password = $User.Password   
    New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "CN=Users,DC=Spiderweb,DC=Local" -ChangePasswordAtLogon $false -PasswordNeverExpires $true 
}          

"""
sample of contents from within AD_User_creation.csv file. 
Name,GivenName,SurName,UserPrincipalName,SamAccountName,Description,Department,EmployeeID,Path,Enabled,Password,PasswordNeverExpires
Aaron Rodgers,Aaron,Rodgers,arodgers@contoso.local,arodgers,,,97368,"CN=Users,DC=Contoso,dc=local",$True,Trust123!,$True
"""
