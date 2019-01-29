$Users = Import-Csv  -Path "C:\Users\oaktree\Desktop\AD_User_creation.csv"            
foreach ($User in $Users)            
{            
    #DC
    $Displayname = $User.Firstname + " " + $User.Lastname            
    $UserFirstname = $User.Firstname            
    $UserLastname = $User.Lastname            
    $OU = $User.OU           
    $SAM = $User.SAM            
    $UPN = $User.Firstname + "." + $User.Lastname + "@" + $User.Maildomain            
    $Description = $User.Description            
    $Password = $User.Password   
    New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false -PasswordNeverExpires $true 
}          

"""
sample of contents from within AD_User_creation.csv file. 
Firstname	Lastname	Maildomain	SAM	OU	Password	Description
Gregg	quintana	contoso.local	gquintana	OU=site DC,OU=Offices, DC=CONTOSO,DC=LOCAL	P@ssword	<description here> 
"""
