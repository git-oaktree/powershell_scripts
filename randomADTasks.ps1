#The majority of this code is not from this author, but rather found online. This is just a repo of that code plus some modifications from the author. 

function resolve-SID($sid)  {
  $objSID = new-object System.Security.Principal.SecurityIdentifier($sid)
  $objSID = $objSID.Translate([System.Security.Principal.NTAccount])_
  return $objSID.Value
 }
 
ResolveSid(<sid here> 
  
