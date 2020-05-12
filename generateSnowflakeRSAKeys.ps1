###################################################################
###################################################################
##        The MIT License - SPDX short identifier: MIT           ##
###################################################################
###################################################################
#
# Copyright (c) 2019 Snowflake Inc. All rights reserved.
#
#Permission is hereby granted, free of charge, to any person obtaining 
#a copy of this software and associated documentation files (the "Software"), 
#to deal in the Software without restriction, including without 
#limitation the rights to use, copy, modify, merge, publish, distribute, 
#sublicense, and/or sell copies of the Software, and to permit persons 
#to whom the Software is furnished to do so, subject to the following 
#conditions:
#
#The above copyright notice and this permission notice shall be 
#included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
#IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
#CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
#TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
#SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

# Please consider this script an example.

###################################################################
###################################################################
##             PLEASE CHANGE THESE VALUES BELOW                  ##
###################################################################
###################################################################

### Location of the Chilkat DLL
$CHILKATDLLFILE = "C:\Users\negasonic\Downloads\ChilkatDotNet47.dll"

### Location to put the private key file - END WITH \ PLEASE
$PRIVATEKEYFILEDIR = "C:\Windows\Temp\"

### Location to put the public key file - END WITH \ PLEASE
$PUBLICKEYFILEDIR = "C:\Windows\Temp\"

###################################################################
###################################################################
##             PLEASE CHANGE THESE VALUES ABOVE                  ##
###################################################################
###################################################################

###################################################################
## Collect some run time values
###################################################################

### Ask for the user name for this key
$UserNameForKey = Read-Host 'What is the username that will use this key?'

### Ask for the passphrase
$KeyPassPhrase = Read-Host 'What is the passphrase you want to use for this key?' -AsSecureString

###################################################################

###################################################################
## Main logic for the script
###################################################################

# Using the Chikat library to do all the mathy bits and formatting
[Reflection.Assembly]::LoadFile("$CHILKATDLLFILE")

# load an RSA object to create keys
$rsa = New-Object Chilkat.Rsa # Chilkat.Rsa GenerateKey

# unlock the DLL licencing, need commercial licence to use long term
# make sure this goes before we bother with the rest bc it's required
$success = $rsa.UnlockComponent("Anything works for 30 day trial")
if ($success -ne $true) {
    $("FATAL:: RSA component unlock failed - check Chilkay library and license")
    exit
}

# create the file names using the user name and the date
$timestamp = Get-Date -Format o | foreach {$_ -replace ":", "."}

$fullPrivateKeyPath = "$($PRIVATEKEYFILEDIR)$($UserNameForKey)-$($timestamp)-privateKey.pem"
$fullPublicKeyPath  = "$($PUBLICKEYFILEDIR)$($UserNameForKey)-$($timestamp)-publicKey.pem"

# Generate a 2048 bit key.  Chilkat RSA supports key sizes ranging from 512 bits to 4096 bits.
$success = $rsa.GenerateKey(2048)
if ($success -ne $true) {
    Out-Host "FATAL ERROR:: "
    $($rsa.LastErrorText)
    exit
}

# Keys are exported in XML format:
$publicKeyXml = $rsa.ExportPublicKey()
$privateKeyXml = $rsa.ExportPrivateKey()

# Save the private key in PEM format:
$privKey = New-Object Chilkat.PrivateKey
$success = $privKey.LoadXml($privateKeyXml)
if ($success -ne $true) {
    Out-Host "FATAL ERROR:: "
    $($privKey.LastErrorText)
    exit
}

# handle the passphrase string during this operation
# Save the private key to encrypted PKCS8 PEM
$success = $privKey.SavePkcs8EncryptedPemFile("$([Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($KeyPassPhrase)))","$fullPrivateKeyPath")
if ($success -ne $true) {
    Out-Host "FATAL ERROR:: "
    $($privKey.LastErrorText)
    exit
}

# Save the public key in PEM format:
$pubKey = New-Object Chilkat.PublicKey
$success = $pubKey.LoadXml($publicKeyXml)
if ($success -ne $true) {
    Out-Host "FATAL ERROR:: "
    $($pubKey.LastErrorText)
    exit
}

$success = $pubKey.SaveOpenSslPemFile("$fullPublicKeyPath")
if ($success -ne $true) {
    Out-Host "FATAL ERROR:: "
    $($pubKey.LastErrorText)
    exit
}

###################################################################
## All's well that ends well
###################################################################
